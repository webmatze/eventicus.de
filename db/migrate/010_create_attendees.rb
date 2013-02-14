class CreateAttendees < ActiveRecord::Migration
  def self.up
    create_table :attendees do |t|#, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column :user_id, :integer
      t.column :event_id, :integer
      t.column "created_at", :datetime, { :null => false }
    end
  end

  def self.down
    drop_table :attendees
  end
end
