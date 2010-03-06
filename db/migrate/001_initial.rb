class Initial < ActiveRecord::Migration
  def self.up
    
    # Erstellt die Users Tabelle und erstellt den Admin User
    create_table :users, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |table|
      table.column :login, :string, { :limit => 80, :null => false }
      table.column :password, :string, { :limit => 40, :null => false }
      table.column :firstname, :string, { :limit => 128, :null => true }
      table.column :name, :string, { :limit => 128, :null => true }
      table.column :email, :string, { :limit => 255, :null => false }
      table.column :url, :string, { :limit => 255, :null => true }
      table.column :avatar_url, :string, { :limit => 255, :null => true }
      table.column :date_created, :datetime, { :null => false }
      table.column :last_login, :datetime, { :null => false }
      table.column :number_of_logins, :integer, { :limit => 11, :null => false }
    end
    User.create(:login => 'admin', 
                :password => 'xxxx',
        				:password_confirmation => 'xxxx',
        				:firstname => 'Eventicus',
        				:name => 'Admin', 
                :email => 'admin@email.com',
        				:url => 'http://eventicus.de',
                :date_created => Time.now,
                :last_login => Time.now,
                :number_of_logins => 0)
    
  end

  def self.down
    drop_table :users    
  end
end
