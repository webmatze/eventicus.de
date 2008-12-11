class Metro < ActiveRecord::Base
	has_many :locations
	
	validates_presence_of :name, :state, :country
	validates_uniqueness_of :name, :scope => [:country, :state]
	
	def event_count
		Event.count_by_sql(["select count(*) from events e, locations l where e.location_id = l.id and l.metro_id = ? and (e.date_start > NOW() or e.date_end > NOW())", self.id])
	end
	
end
