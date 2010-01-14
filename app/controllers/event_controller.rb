class EventController < ApplicationController

  before_filter :login_required, :except => [:about, :index, :list, :show, :sitemap]
  layout 'eventicus'

  def initialize
    @flickr = Flickr.new("4784db08dc2755cdf36fc653a6ff3920")
  end

  def auto_complete_for_tmplocation_name
    @locations = Location.find(:all,
      :conditions => [ 'LOWER(name) LIKE ?', '%' + params[:tmplocation][:name] + '%'],
      :order => 'name ASC',
      :limit => 8)
      render :partial => 'locations'
  end

  def auto_complete_for_tmpmetro_name
    @metros = Metro.find(:all,
      :conditions => [ 'LOWER(name) LIKE ?', '%' + params[:tmpmetro][:name] + '%'],
      :order => 'name ASC',
      :limit => 8)
      render :partial => 'metros'
  end

  def selected_venue
    @location = Location.find_by_id params[:id]
  	render :partial => 'selectedvenue'
  end

  def selected_metro
    @metro = Metro.find_by_id params[:id]
  	render :partial => 'selectedmetro'
  end

  def add_location
	  render :partial => 'addlocation'
  end

  def index
    list
    render :action => 'list'
  end
  
  def about
  end
  
  def sitemap
    @events = Event.find(:all, :order => "date_start DESC")
    render :layout => false
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update, :add_comment ],
         :redirect_to => { :action => :list }

  def list
    store_location
    @metros = metrolist(params)
	  @events = eventlist(params, 6, params[:page].to_i)
  end
  
  def search
    
  end

  def show
    store_location
    @event = Event.find(params[:id])
    @event.add_popularity(1)
    params[:category] = @event.category.short
    @photos = @flickr.photos(:tags => "eventicus:event=" + @event.id.to_s) rescue []
  end

  def new
    @event = Event.new
    @event.date_start = Time.zone.now 
    @event.date_end = @event.date_start + 2.hours
  end

  def create
    @event = Event.new(params[:event])
	  @event.user = session['user']
    @event.prepare_dates
    if @event.save
      flash[:notice] = t(:event_successful_created)
      redirect_to events_url(:category => @event.category.short)
    else
      render :action => 'new'
    end
  end
  
  def add_comment
    event = Event.find(params[:id])
  	@comment = Comment.new(params[:comment])
    @comment.user_id = session['user'].id
    if event.add_comment @comment
      render :partial => 'comment'
    end
  end
  
  def attend
    event = Event.find(params[:id])
    attendee = Attendee.create
    attendee.event = event
    attendee.user = session['user']
    attendee.save
    redirect_back_or_default events_url
  end
  
  def notattending
    event = Event.find(params[:id])
    attendee = event.attendees.find_by_user_id session['user'].id
    attendee.destroy
    redirect_back_or_default :action => 'show', :id => event
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    @event.attributes = params[:event]
    @event.prepare_dates
    if @event.save
      flash[:notice] = t(:event_successful_updated)
      redirect_to :action => 'show', :metro => @event.location.metro, :id => @event
    else
      render :action => 'edit'
    end
  end

  def destroy
    Event.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def import
    url = params[:url]
    if url
      if url.starts_with? "http://"
        begin
          
          hCal = hCalendar.find url

          if hCal == nil
             flash[:notice] = 'There are no microformat hCalendar informations for this event'
             redirect_to :action => "import"
          end

          if Event.find_by_title_and_date_start hCal.summary, hCal.dtstart
             flash[:notice] = 'Event has already been imported by someone else'
             redirect_to :action => "import"
          end
          
          if hCal.properties.index("location")
            hLoc = hCal.location
          else
            cards = hCard.find url
            hLoc = (cards.class.name == "HCard") ? cards : cards.first
          end
          
          @event = Event.new
          @event.title = hCal.summary if hCal.properties.index("summary")
          @event.description = hCal.description if hCal.properties.index("description")
          @event.date_start = hCal.dtstart if hCal.properties.index("dtstart")
          @event.date_end = hCal.properties.index("dtend") ? hCal.dtend : hCal.dtstart + 2.hours
          
          @location = Location.find_by_name hLoc.fn if hLoc

          if @location.nil?
          
            @location = Location.new
            
            if hLoc
            
              @location.name = hLoc.fn
              @location.url = hLoc.properties.index("url") ? hLoc.url : ""
              @location.description = ""
              @location.email = ""
              @location.street = hLoc.adr.street_address
              @location.zip = hLoc.adr.properties.index("postal_code") ? hLoc.adr.postal_code : ""
              @location.phone = ""
  
              if hLoc.properties.index("geo")
                @location.lat = hLoc.geo.latitude.to_s
                @location.lng = hLoc.geo.longitude.to_s
              end
  
              @metro = Metro.find_by_name hLoc.adr.locality
              if @metro == nil
                  @metro = Metro.new
                  @metro.name = hLoc.adr.locality
                  @metro.country = hLoc.properties.index("country_name") ? hLoc.country_name : ""
                  @metro.state = hLoc.adr.region if hLoc.adr.properties.index("region")
              end
              
            else
              
              @metro = Metro.new
              
            end
            
            @location.metro = @metro
            
          else
          
            @metro = @location.metro
           
          end
          
          @event.location = @location
          
        rescue Timeout::Error
          flash[:notice] = 'Timeout on reading url'
        rescue Exception => e
          flash[:notice] = 'Event could not be imported: ' + e
        end
        
      else
        flash[:notice] = "URL has to start with 'http://'"
      end
      
    end
  end
  
  def save_import
    save_event = true

    @event = Event.new(params[:event])
    
    if params[:metro][:id] != nil
      @metro = Metro.find params[:metro][:id]
    else
      @metro = Metro.new(params[:metro])
      save_event = @metro.save
    end

    if params[:location][:id] != nil
      @location = Location.find params[:location][:id]
    else
      @location = Location.new(params[:location])
      @location.metro = @metro
      if save_event
        save_event = @location.save
      end
    end
    
    @event.location = @location
  
    if save_event
      @event.user = session['user']
      @event.location = @location
      
      @event.date_start = Time.zone.local_to_utc(@event.date_start)
      @event.date_end = Time.zone.local_to_utc(@event.date_end)

      if @event.save
        flash[:notice] = 'Event was successfully imported.'
        redirect_to events_url(:category => @event.category.short) and return if true
      else
        render :action => 'import'
      end
    else
      render :action => 'import'
    end
      
  end

  private
  
    def metrolist(params)
      Metro.find_by_sql("SELECT m.*
                        FROM metros m, events e, locations l
                        WHERE e.location_id = l.id
                        AND l.metro_id = m.id
                        AND (e.date_start > NOW() OR e.date_end > NOW())
						GROUP BY m.id ORDER BY m.name ASC;");
    end
end
