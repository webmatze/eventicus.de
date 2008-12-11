class Location < ActiveRecord::Base
	belongs_to :metro
	has_many :events
	
	acts_as_mappable
	
	validates_presence_of :name, :street, :zip, :metro
	validates_uniqueness_of :name, :scope => :metro_id
	
	def to_ical
		ical = Icalendar::Calendar.new
		ical.product_id = "-//eventicus.com//iCal 1.0//EN"
		events.each do |event|
			ical.add_event(event.to_ical_event)
		end
		ical
	end
	
end
