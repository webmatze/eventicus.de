class ChangeUserTimezones < ActiveRecord::Migration
  def self.up
    User.all.each do |u|
      u.time_zone = u.time_zone.split("/").reverse.first
      u.save
    end
  end

  def self.down
  end
end
