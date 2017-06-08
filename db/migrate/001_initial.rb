class Initial < ActiveRecord::Migration
  def self.up

    # Erstellt die Users Tabelle und erstellt den Admin User
    create_table :users do |table|#, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |table|
      table.column :login, :string, { :limit => 80, :null => false }
      table.column :password, :string, { :limit => 40, :null => false }
      table.column :firstname, :string, { :limit => 128, :null => true }
      table.column :name, :string, { :limit => 128, :null => true }
      table.column :email, :string, { :limit => 255, :null => false }
      table.column :url, :string, { :limit => 255, :null => true }
      table.column :avatar_url, :string, { :limit => 255, :null => true }
      table.column :last_login, :datetime, { :null => true }
      table.column :number_of_logins, :integer, { :limit => 11, :null => false }
      table.timestamps
    end
    User.create(:login => 'admin',
                :password => 'xxxx',
        				:password_confirmation => 'xxxx',
        				:firstname => 'Eventicus',
        				:name => 'Admin',
                :email => 'admin@eventicus.de',
        				:url => 'http://eventicus.de',
                :last_login => Time.now,
                :number_of_logins => 0)

  end

  def self.down
    drop_table :users
  end
end
