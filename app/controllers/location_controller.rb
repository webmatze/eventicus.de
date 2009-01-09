class LocationController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @location_pages, @locations = paginate :locations, :per_page => 10
  end

  def show
    @location = Location.find(params[:id])
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(params[:location])
    if @location.save
      flash[:notice] = 'Location was successfully created'.t
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def ajax_create
    @location = Location.new(params[:location])
    searchStr = ""
    searchStr << @location.street + ", "
    searchStr << @location.zip + " " + @location.metro.name + ", " + @location.metro.country if @location.metro
    loc = GeoKit::Geocoders::GoogleGeocoder.geocode(searchStr)
    if loc.success
      @location.lat = loc.lat
      @location.lng = loc.lng
    end
    if @location.save
      render :partial => 'event/selectedvenue'
    else
      text = "";
      for error in @location.errors.full_messages do
        text += "<li>" + error + "</li>"
      end
      render :text => text, :status => 444
    end
  end

  def edit
    @location = Location.find(params[:id])
  end

  def update
    @location = Location.find(params[:id])
    if @location.update_attributes(params[:location])
      flash[:notice] = 'Location was successfully updated'.t
      redirect_to :action => 'show', :id => @location
    else
      render :action => 'edit'
    end
  end

  def destroy
    Location.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
