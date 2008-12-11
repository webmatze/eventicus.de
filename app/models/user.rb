require 'digest/sha1'

# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base

	has_many :events, :order => 'date_created DESC'
  has_many :attendees
  has_many :attended_events, :through => :attendees, :source => :event
  
  composed_of :tz, :class_name => 'TZInfo::Timezone', :mapping => %w( time_zone time_zone )

  def self.authenticate(login, pass)
    if user = first(:conditions => ["login = ? AND password = ?", login, sha1(pass)])
      user.last_login = TzTime.now.utc
      if user.increment :number_of_logins, 1
        return user
      end
	  end
  end  

  def change_password(pass)
    update_attribute "password", self.class.sha1(pass)
  end
    
  protected

  def self.sha1(pass)
    Digest::SHA1.hexdigest("change-me--#{pass}--")
  end
    
  before_create :crypt_password, :init_user
  
  def crypt_password
    write_attribute("password", self.class.sha1(password))
  end

	def init_user
		write_attribute("date_created", TzTime.now.utc)
		write_attribute("last_login", TzTime.now.utc)
		write_attribute("number_of_logins", 0)
	end

  validates_length_of :login, :within => 3..40
  validates_length_of :password, :within => 5..40
  validates_presence_of :login, :password, :password_confirmation, :on => :create
  validates_uniqueness_of :login, :on => :create
  validates_confirmation_of :password, :on => :create     
end
