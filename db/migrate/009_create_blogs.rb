class CreateBlogs < ActiveRecord::Migration
  def self.up
    create_table :blogs do |t|#, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column "title", :string, { :limit => 128, :null => false }
      t.column "description", :text
      t.column "user_id", :integer, { :null => false }
      t.timestamps
    end
  end

  def self.down
    drop_table :blogs
  end
end
