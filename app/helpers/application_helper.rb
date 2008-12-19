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
			return Metro.find_by_name(param)
		end 
	end
	
	def nl2br(s)
		s.gsub(/\n/, '<br>')
	end	
	
	def get_recent_blogposts
		@recentblogposts = Blog.find(:all, :order => "created_at DESC", :limit => 5);
	end
	
	def tz(time_at)
		TzTime.zone.utc_to_local(time_at.utc)
	end

	def time_ago_or_time_stamp(from_time, to_time = Time.now, include_seconds = true, detail = false)
	  from_time = from_time.to_time if from_time.respond_to?(:to_time)
	  to_time = to_time.to_time if to_time.respond_to?(:to_time)
	  distance_in_minutes = (((to_time - from_time).abs)/60).round
	  distance_in_seconds = ((to_time - from_time).abs).round
	  case distance_in_minutes
		when 0..1           then time = (distance_in_seconds < 60) ? "#{distance_in_seconds} seconds ago" : '1 minute ago'
		when 2..59          then time = "#{distance_in_minutes} minutes ago"
		when 60..90         then time = "1 hour ago"
		when 90..1440       then time = "#{(distance_in_minutes.to_f / 60.0).round} hours ago"
		when 1440..2160     then time = '1 day ago' # 1-1.5 days
		when 2160..10080     then time = "#{(distance_in_minutes.to_f / 1440.0).round} days ago" # 1.5-7 days
		else time = from_time.strftime("%a, %d %b %Y")
	  end
	  return time_stamp(from_time) if (detail && distance_in_minutes > 10080)
	  return time
	end

  def avatar_for(user, size = nil) 
    if user.avatar 
      avatar_image = size.nil? ? user.avatar.public_filename : user.avatar.public_filename(size) 
      image_tag(avatar_image)
    else 
      if size.nil?
        image_tag("default-avatar.png")         
      else
        image_tag("default-avatar-#{size}.png") 
      end
    end 
  end 

end
