class IcalController < ApplicationController
  
	def events
		events = eventlist(params, 25, 1)
		
		@ical = Icalendar::Calendar.new
		@ical.product_id = "-//eventicus.com//iCal 1.0//EN"
		@ical.custom_property("X-WR-CALNAME;VALUE=TEXT", "Eventicus Events");
		events.each do |event|
			ical_event = event.to_ical_event
			ical_event.url = event_url(:id => event.id)
			ical_event.description = "More info at: " + event_url(:id => event.id)
			@ical.add_event(ical_event)
		end
		@ical.publish
		headers["Content-Type"] = "text/calendar; charset=UTF-8"
		render :layout => false, :text => @ical.to_ical
	end

end
