# == Usage ==
# Using the defaults:
#   require_bundle :dynarch_calendar
#
# Or with some optional parameters:
#   require_bundle :dynarch_calendar, :color => 'green', :language => 'en', :icon => '/images/my_calendar.gif'
#
# See the 'lang/' folder inside the dynarch bundle for a list of valid language options.
# See the 'stylesheets/' folder inside the dynarch bundle for a list of valid color options.
#
# 1. Use the 'dynarch_date_select' method in place of Rails' date_select:
#   <%= dynarch_date_select 'user', 'birthday' %>
#
#   Using this method will first call the Rails built-in date_select method
#   so that browsers that don't support javascript can still work.
#
#   If javascript is enabled, however, the ugly data select drop-downs
#   will subsequently be replaced by the snazzy dynarch calendar.
#
# 2. Note that convert_date_to_multi_params! is no longer needed, and in fact has
#    been removed as of bundled_resource 0.8.
#
# == Full Dynarch Calendar Documentation ==
# ?

module BundledResource::DynarchCalendar
  mattr_accessor :icon
  
  # As of bundled_resource 0.8, it is no longer necessary to use the 'convert_date_to_multi_params!'
  # method in your controller.  Everything should 'just work'.
  def bundle(options = {})
    defaults = {:language => 'en', :color => 'blue', :stripped => true, :icon => 1}
    options = defaults.merge(options)
    require_stylesheet "/bundles/dynarch_calendar/stylesheets/calendar-#{options[:color]}"

    require_javascript "/bundles/dynarch_calendar/javascripts/calendar#{options[:stripped] ? '_stripped' : ''}"
    require_javascript "/bundles/dynarch_calendar/lang/calendar-#{options[:language]}"
    require_javascript "/bundles/dynarch_calendar/javascripts/calendar-setup#{options[:stripped] ? '_stripped' : ''}"
    require_javascript "/bundles/dynarch_calendar/javascripts/convert_calendar_field"

    if options[:icon].is_a? Fixnum
      BundledResource::DynarchCalendar.icon = "/bundles/dynarch_calendar/images/calendar_icon#{options[:icon]}.gif"
    else
      BundledResource::DynarchCalendar.icon = options[:icon]
    end
  end
  
  module Helper
    #Timezone conversion
    def tz(time_at)
      TzTime.zone.utc_to_local(time_at.utc)
    end
    # Shows a calendar image that the user can click on to show a pop-up Dynarch calendar.
    def dynarch_date_select(object_name, method_name, options = {})
      image_url = BundledResource::DynarchCalendar.icon
      container_id = "#{object_name}" + (options[:index] ? "_#{options[:index]}" : "") + "_#{method_name}_container"
      index = options[:index] ? "'#{options[:index]}'" : "null"
      object = instance_variable_get("@#{object_name}")
      date_format = options[:date_format] || "%A, %B %d, %Y"
      datetime = tz(((object.send(method_name) || Time.now) rescue Time.now))
      initial_date = datetime.strftime("%m/%d/%Y %H:%M")
      initial_display = datetime.strftime(date_format)
      buffer = ""
      buffer << content_tag('span', date_select(object_name, method_name, options) + "\n", :id => container_id)
      buffer << "<script>convert_date_container_to_dynarch_calendar('#{object_name}', '#{method_name}', #{index}, '#{initial_date}', '#{initial_display}', '#{image_url}')</script>\n"
    end

    # If you want a drop-down to select the hour and minute, use :select_time => true.
    # Otherwise, two text fields will be used.
    def dynarch_time_select(object_name, method_name, options = {})
      defaults = { :discard_type => true, :select_time => false, :minute_step => 5 }
      options = defaults.merge(options)
      object = instance_variable_get("@#{object_name}")
      datetime = tz(((object.send(method_name) || Time.now) rescue Time.now))
      options_with_prefix = Proc.new { |position| options.merge(:prefix => "#{object_name}[#{method_name}(#{position}i)]") }
      buffer = ""
      twelve_hour = datetime.hour >= 12 ? datetime.hour - 12 : datetime.hour
      twelve_hour = 12 if twelve_hour == 0
      if options[:select_time]
        buffer << select_hour(datetime, options_with_prefix.call(4)) << ':'
        #buffer << select_twelve_hour(datetime, options_with_prefix.call(4)) << ':'
        buffer << select_minute(datetime, options_with_prefix.call(5))
      else
        buffer << text_field_tag("#{object_name}[#{method_name}(4i)]", datetime.hour, :size => 2) << ':'
        #buffer << text_field_tag("#{object_name}[#{method_name}(4i)]", twelve_hour, :size => 2) << ':'
        buffer << text_field_tag("#{object_name}[#{method_name}(5i)]", datetime.min, :size => 2)
      end
      #buffer << select_am_pm(datetime, options_with_prefix.call(6))
    end

    def dynarch_datetime_select(object, method, options = {})
      dynarch_date_select(object, method, options) +
      (options[:separator] || ' at ') + 
      dynarch_time_select(object, method, options)
    end
  end  
end


module ActionView::Helpers::DateHelper
  
  def select_twelve_hour(datetime, options = {})
    hour_options = []

    0.upto(11) do |hour|
      if datetime
        datetime_hour = (datetime.kind_of?(Fixnum) ? datetime : datetime.hour)
        selected = ' selected' if datetime_hour == hour or (datetime_hour - 12) == hour
      else
        selected = ''
      end
      hour_options << 
        %(<option value="#{leading_zero_on_single_digits(hour)}"#{selected}>#{hour == 0 ? 12 : hour}</option>\n)
    end

    RAILS_DEFAULT_LOGGER.warn "select twelve hour prefix: #{options[:prefix]}"
    #select_html(options[:field_name] || 'hour', hour_options, options[:prefix], options[:include_blank], options[:discard_type], options[:disabled])
    select_html(options[:field_name] || 'hour', hour_options, options)
  end
  
  def select_am_pm(datetime, options = {})
    am_pm_options = []

    ['AM', 'PM'].each do |am_pm|
      if datetime
        datetime_am_pm = (datetime.kind_of?(String) ? datetime : datetime.strftime("%p"))
        selected = ' selected' if datetime_am_pm == am_pm
      else
        selected = ''
      end
      am_pm_options << 
        %(<option value="#{am_pm}"#{selected}>#{am_pm}</option>\n)
    end

	# select_html(options[:field_name] || 'am_pm', am_pm_options, options[:prefix], options[:include_blank], options[:discard_type], options[:disabled])
	select_html(options[:field_name] || 'am_pm', am_pm_options, options)
  end
end

class ::DateTime
  alias dynarch_original_initialize initialize
  def initialize(*args)
    # Allow the 6th parameter, which is normally seconds, to contain 'AM' or 'PM'
    if args.size >= 6
      if args[5] == 'PM' and args[3] < 12
        args[3] += 12
        args[5] = nil
      elsif args[5] == 'AM'
        args[5] = nil
      end
    end
    dynarch_original_initialize(*args)
  end
end