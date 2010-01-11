class Category < ActiveRecord::Base
	has_many :events
	
	validates_presence_of :name, :on => :create, :message => "can't be blank"
	validates_presence_of :ordering, :on => :create, :message => "can't be blank"
	validates_presence_of :short, :on => :create, :message => "can't be blank"
end
