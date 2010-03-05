class InitFbEmailHashes < ActiveRecord::Migration
  def self.up
    User.all.each do |u|
      u.register_user_to_fb
    end
  end

  def self.down
  end
end
