class Event < ActiveRecord::Base
	belongs_to :location
	belongs_to :user
	belongs_to :category
	
	has_many :attendees, :dependent => :destroy
	has_many :attending_users, :through => :attendees, :source => :user

  has_friendly_id :title, :use_slug => true, :strip_diacritics => true, :reserved => ["new","edit","delete"]
	
	acts_as_commentable
	
	#tz_time_attributes :date_start, :date_end, :date_created, :date_modified
	
	
	validates_presence_of	:title, :description, :date_start
	
	before_create :initialize_datecreated
	before_update :initialize_datemodified
	
	before_create :prepare_dates
	before_update :prepare_dates
	
	def add_popularity(amount)
		self.update_attributes :popularity => self.popularity + amount
	end
	
	def to_ical_event
		ical_event = Icalendar::Event.new
		ical_event.start = tz(date_start).to_datetime
		ical_event.end = tz(date_end).to_datetime
		ical_event.created = tz(date_created).to_datetime
		ical_event.dtstamp = tz(date_created).to_datetime
		ical_event.summary = title
		ical_event.location = location.name + ", " + location.street + ", " + location.metro.name + ", " + location.metro.country
		ical_event.geo = location.lat.to_s + ";" + location.lng.to_s if location.lat
		ical_event.uid = "eventicus-#{id}"
		ical_event
	end
	
	def prepare_dates
		self.date_start = local_to_utc(self.date_start).to_time
		self.date_end = local_to_utc(self.date_end).to_time
	end
	
	protected

		def validate
			errors.add(t(:end_date), t(:end_date_error)) unless self.date_start < self.date_end
			errors.add(t(:venue), t(:venue_error)) unless self.location
			errors.add(t(:category), t(:is_required)) unless self.category
		end
	
	private


		def tz(time_at)
			Time.zone.utc_to_local(time_at.utc)
		end
		
		def local_to_utc(time)
			Time.zone.local_to_utc(time)
		end
	
		def initialize_datecreated
			self.date_created = local_to_utc(Time.now).to_time
		end
		
		def initialize_datemodified
		  #Folgendes für friendly_id Slug generator
		  Time.zone = ActiveSupport::TimeZone.new("Berlin") if Time.zone.nil?
			self.date_modified = local_to_utc(Time.now).to_time
		end

end
