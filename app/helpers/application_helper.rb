# Methods added to this helper will be available to all templates in the application.

module ApplicationHelper
	
	def active_category
		Category.find_by_short(params[:category]);
	end
	
	def categories
		Category.find( :all, :order => "ordering ASC")
	end
	
	def categories_for_select
		Category.find( :all, :order => "ordering ASC", :conditions => "short <> 'all'")
	end
	
	def ranges
		[
			{:key => "all" ,:title => "All"},
			{:key => "today", :title => "Today"},
			{:key => "week", :title => "This week"},
			{:key => "month", :title => "This month"},
			{:key => "year", :title => "This year"}
		]
	end
	
	def range_by_short( short ) 
		self.ranges.each do |range|
			return range if range[:key] == short
		end
	end
	
	def metro_by_param( param )
		if param.to_i > 0
			return Metro.find_by_id(param)
		else
			return Metro.find(param)
		end 
	end
	
	def nl2br(s)
		s.gsub(/\n/, '<br>')
	end	
	
	def get_recent_blogposts
		@recentblogposts = Blog.find(:all, :order => "created_at DESC", :limit => 5);
	end
	
	def tz(time_at)
		Time.zone.utc_to_local(time_at.utc)
	end

	def time_ago_or_time_stamp(from_time, to_time = Time.now, include_seconds = true, detail = false)
	  from_time = from_time.to_time if from_time.respond_to?(:to_time)
	  to_time = to_time.to_time if to_time.respond_to?(:to_time)
	  distance_in_minutes = (((to_time - from_time).abs)/60).round
	  distance_in_seconds = ((to_time - from_time).abs).round
	  case distance_in_minutes
		when 0..1           then time = (distance_in_seconds < 60) ? t(:"time.seconds_ago", :seconds => distance_in_seconds) : t(:"time.one_minute_ago")
		when 2..59          then time = t(:"time.minutes_ago", :minutes => distance_in_minutes)
		when 60..90         then time = t(:"time.one_hour_ago")
		when 90..1440       then time = t(:"time.hours_ago", :hours => (distance_in_minutes.to_f / 60.0).round)
		when 1440..2160     then time = t(:"time.one_day_ago") # 1-1.5 days
		when 2160..10080     then time = t(:"time.days_ago", :days => (distance_in_minutes.to_f / 1440.0).round) # 1.5-7 days
		else time = t(:"time.on_date", :date => from_time.to_date.strftime("%d. %B %Y"))
	  end
	  return time_stamp(from_time) if (detail && distance_in_minutes > 10080)
	  return time
	end

  def avatar_for(user, size = nil, html_options = {})
    if user.avatar 
      avatar_image = size.nil? ? user.avatar.public_filename : user.avatar.public_filename(size) 
      image_tag(avatar_image, html_options)
    else 
      if size.nil?
        image_tag("default_avatar.png", html_options)         
      else
        image_tag("default_avatar_#{size}.png", html_options) 
      end
    end 
  end 

end
