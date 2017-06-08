class Categories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|#, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column "name", :string, { :limit => 128, :null => false }
      t.column "short", :string, { :limit => 32, :null => false }
      t.timestamps
    end
  end

  def self.down
    drop_table "categories"
  end
end
