require 'digest/sha1'

# this model expects a certain database layout and its based on the name/login pattern.
class User < ActiveRecord::Base

	has_many :events, :order => 'date_created DESC'
  has_many :attendees
  has_many :attended_events, :through => :attendees, :source => :event

  has_one :avatar, :dependent => :destroy

  composed_of :tz, :class_name => 'TZInfo::Timezone', :mapping => %w( time_zone time_zone )

  has_friendly_id :login, :use_slug => true, :approximate_ascii => true, :reserved_words => ["new","index","show","delete","update"]

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
    self.increment :number_of_logins, 1
    self.update_attribute "last_login", Time.zone.now.utc
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
