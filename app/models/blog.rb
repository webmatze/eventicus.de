class Blog < ActiveRecord::Base
	belongs_to :user
	
	has_friendly_id :title, :use_slug => true, :approximate_ascii => true, :reserved_words => ["new","edit","delete"]
  
	acts_as_commentable
	
	validates_presence_of :title, :description
	
end
