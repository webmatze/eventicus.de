class UserTimezoneSupport < ActiveRecord::Migration
  def self.up
    add_column :users, "time_zone", :string, :default => "UTC", :null => false, :limit => 128
  end

  def self.down
    remove_column :users, "time_zone"
  end
end
