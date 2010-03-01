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
	
	def geocode
	  searchStr = ""
    searchStr << self.street
    searchStr << ", " + self.zip + " " + self.metro.name + ", " + self.metro.country if self.metro
    loc = GeoKit::Geocoders::MultiGeocoder.geocode(searchStr)
    if loc.success
      self.lat = loc.lat
      self.lng = loc.lng
    end
	end
	
	def geocoded?
	 !self.lat.nil? && !self.lng.nil?
	end
	
end
