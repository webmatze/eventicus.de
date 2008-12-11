class Events < ActiveRecord::Migration
  def self.up
	create_table :events, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
	    t.column "title", :string, { :limit => 128, :null => false }
		t.column "description", :text
		t.column "date_start", :datetime, { :null => false }
		t.column "date_end", :datetime
		t.column "date_created", :datetime, { :null => false }
		t.column "date_modified", :datetime
		t.column "user_id", :integer, { :null => false }
		t.column "location_id", :integer, { :null => false }
	end
	create_table :metros, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
	    t.column "name", :string, { :limit => 128, :null => false }
		t.column "state", :string, { :limit => 128, :null => false }
		t.column "country", :string, { :limit => 128, :null => false }
	end
	create_table :locations, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
	    t.column "name", :string, { :limit => 128, :null => false }
		t.column "street", :string, { :limit => 128 }
		t.column "zip", :string, { :limit => 10 }
		t.column "url", :string, { :limit => 255 }
		t.column "email", :string, { :limit => 255 }
		t.column "description", :text
		t.column "phone", :string, { :limit => 128 }
		t.column "metro_id", :integer, { :null => false }
	end
  end

  def self.down
	drop_table :events
	drop_table :metros
	drop_table :locations
  end
end
