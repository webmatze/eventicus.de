# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require_dependency "login_system"

class ApplicationController < ActionController::Base

  include LoginSystem

  before_filter :set_timezone

  # Pick a unique cookie name to distinguish our session data from others'
  #session :session_key => '_eventicus2_session_id'
  
  before_filter :set_charset
  before_filter :set_locale
  
  protected
  
    def get_eventlist_conditions( params )
      conditions = Array.new
      condParams = Hash.new
      category = ""
      range = ""
      place = ""
      search = ""
      #place
      if params[:place] != 'world'
        metro_id = params[:place]
        metro = Metro.find(metro_id)
        metro_id = metro.id 
        place = "l.metro_id = " + metro_id.to_s + " AND "
      end
      #category
      if params[:category] != 'all'
        category = "e.category_id = " + Category.find_by_short(params[:category]).id.to_s + " AND "
      end
      #range
      if params[:range] == 'all'
        range = "(e.date_start > :rangeStart OR e.date_end > :rangeStart) ";
        condParams[:rangeStart] = Time.zone.now
      end
      if params[:range] == 'today'
        range = "(e.date_start BETWEEN :rangeStart AND :rangeEnd OR e.date_end BETWEEN :rangeStart AND :rangeEnd OR :rangeStart BETWEEN e.date_start AND e.date_end) ";
        condParams[:rangeStart] = Time.zone.now
        condParams[:rangeEnd] = Time.zone.today.at_beginning_of_day + 1.day
      end
      if params[:range] == 'week'
        condParams[:rangeStart] = Time.zone.now.utc
        condParams[:rangeEnd] = (Time.zone.today.beginning_of_week + 1.week).beginning_of_day
        range = "(e.date_start BETWEEN :rangeStart AND :rangeEnd OR e.date_end BETWEEN :rangeStart AND :rangeEnd OR :rangeStart BETWEEN e.date_start AND e.date_end) "
      end
      if params[:range] == 'month'
        condParams[:rangeStart] = Time.zone.now.utc
        condParams[:rangeEnd] = Time.zone.today.end_of_month + 1.day
        range = "(e.date_start BETWEEN :rangeStart and :rangeEnd OR e.date_end BETWEEN :rangeStart and :rangeEnd OR :rangeStart BETWEEN e.date_start AND e.date_end) "
      end
      if params[:range] == 'year'
        condParams[:rangeStart] = Time.zone.now.utc
        condParams[:rangeEnd] = (Time.zone.today.beginning_of_year + 1.year).beginning_of_day
        range = "(e.date_start BETWEEN :rangeStart and :rangeEnd OR e.date_end BETWEEN :rangeStart and :rangeEnd OR :rangeStart BETWEEN e.date_start AND e.date_end) "
      end
      if params[:search]
        condParams[:searchKey] = "%" + params[:search] + "%"
        search = " (e.title like :searchKey OR e.description like :searchKey) AND "
      end
      if params[:where]
        name = params[:where]
        search += " (l.name like '%#{name}%' OR l.street like '%#{name}%' OR m.name like '%#{name}%' OR m.state like '%#{name}%' OR m.country like '%#{name}%') AND "
      end
      conditions = [place + category + search + range, condParams]
    end

    def count_events( params )
      Event.count(
        :all, 
        :select => "events e",
        :joins => "LEFT JOIN locations l ON l.id = e.location_id LEFT JOIN metros m ON m.id = l.metro_id " , 
        :conditions => get_eventlist_conditions(params)
      )
    end

    def eventlist( params , per_page = 6, page = 1)
      order = "";
      conditions = get_eventlist_conditions(params)
      #type
      if params[:type] == 'upcoming'
        order = "date_start ASC"
      else
        order = "popularity DESC, date_start ASC"
      end

      #find
      if conditions.length > 0
        Event.paginate(
          :all, 
          :order => order, 
          :select => "e.*", 
          :from => "events e", 
          :conditions => conditions, 
          :joins => "LEFT JOIN locations l ON l.id = e.location_id LEFT JOIN metros m ON m.id = l.metro_id" , 
          :per_page => per_page, 
          :page => page)
      else
        Event.paginate(:all, :order => order, :per_page => per_page, :page => page)
      end
    end
    
  private
  
    def set_charset
        content_type = headers["Content-Type"] || "text/html" 
        if /^text\//.match(content_type)
          headers["Content-Type"] = "#{content_type}; charset=utf-8" 
        end
    end
  
    def set_timezone
      Time.zone = @current_user.time_zone if @current_user
      #if session['user'] && !session['user'].time_zone.nil?
      #  TzTime.zone = session['user'].tz
      #else
      #  TzTime.zone = TZInfo::Timezone.new("Europe/Berlin")
      #end
      #yield
      #TzTime.reset!
    end
     
    def set_locale
     default_locale = 'de-DE'
     request_language = request.env['HTTP_ACCEPT_LANGUAGE']
     request_language = request_language.nil? ? nil : 
       request_language[/[^,;]+/]

    request_language = default_locale if request_language != "en-US"

     @locale = params[:locale] || session[:locale] ||
               request_language || default_locale
     session[:locale] = @locale
     begin
       #Locale.set @locale
       I18n.locale = @locale
     rescue
       #Locale.set default_locale
       I18n.locale = :en
     end
     WillPaginate::ViewHelpers.pagination_options[:previous_label] =  '&lt;- ' + t(:previous)
     WillPaginate::ViewHelpers.pagination_options[:next_label] = t(:next) + ' -&gt;'
    end
 
end
