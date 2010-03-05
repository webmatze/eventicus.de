require 'digest/sha1'

# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base

	has_many :events, :order => 'date_created DESC'
  has_many :attendees
  has_many :attended_events, :through => :attendees, :source => :event
  
  has_one :avatar, :dependent => :destroy
  
  composed_of :tz, :class_name => 'TZInfo::Timezone', :mapping => %w( time_zone time_zone )
  
  has_friendly_id :login, :use_slug => true, :strip_diacritics => true, :reserved => ["new","index","show","delete","update"]

  after_create :register_user_to_fb

  def self.authenticate(login, pass)
    if user = first(:conditions => ["login = ? AND password = ?", login, sha1(pass)])
      user.count_login
      return user
	  end
  end  

  def change_password(pass)
    update_attribute "password", self.class.sha1(pass)
  end
  
  def count_login
    user.increment :number_of_logins, 1
    user.update_attribute "last_login", Time.zone.now.utc
  end
  
	#find the user in the database, first by the facebook user id and if that fails through the email hash
  def self.find_by_fb_user(fb_user)
    User.find_by_fb_user_id(fb_user.uid) || User.find_by_email_hash(fb_user.email_hashes)
  end
  
  #Take the data returned from facebook and create a new user from it.
  #We don't get the email from Facebook and because a facebooker can only login through Connect we just generate a unique login name for them.
  #If you were using username to display to people you might want to get them to select one after registering through Facebook Connect
  def self.create_from_fb_connect(fb_user)
    new_facebooker = User.find_by_fb_user(fb_user)
    if new_facebooker.nil?
      new_facebooker = User.new(:login => fb_user.name, :password => "", :email => "")
      new_facebooker.fb_user_id = fb_user.uid.to_i
      #We need to save without validations
      new_facebooker.save(false)
    end
    new_facebooker.register_user_to_fb
  end

  #We are going to connect this user object with a facebook id. But only ever one account.
  def link_fb_connect(fb_user_id)
    unless fb_user_id.nil?
      #check for existing account
      existing_fb_user = User.find_by_fb_user_id(fb_user_id)
      #unlink the existing account
      unless existing_fb_user.nil?
        existing_fb_user.fb_user_id = nil
        existing_fb_user.save(false)
      end
      #link the new one
      self.fb_user_id = fb_user_id
      save(false)
    end
  end

  #The Facebook registers user method is going to send the users email hash and our account id to Facebook
  #We need this so Facebook can find friends on our local application even if they have not connect through connect
  #We hen use the email hash in the database to later identify a user from Facebook with a local user
  def register_user_to_fb
    users = {:email => email, :account_id => id}
    Facebooker::User.register([users])
    self.email_hash = Facebooker::User.hash_email(email)
    save(false)
  end
  
  def facebook_user?
    return !fb_user_id.nil? && fb_user_id > 0
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
		write_attribute("date_created", Time.zone.now.utc)
		write_attribute("last_login", Time.zone.now.utc)
		write_attribute("number_of_logins", 0)
	end

  validates_length_of :login, :within => 3..40
  validates_length_of :password, :within => 5..40
  validates_presence_of :login, :password, :password_confirmation, :email, :on => :create
  validates_presence_of :login, :on => :update
  validates_uniqueness_of :login, :email, :on => :create
  validates_uniqueness_of :login, :on => :update
  validates_confirmation_of :password, :if => :password_changed?    
end
