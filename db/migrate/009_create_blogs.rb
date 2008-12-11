class CreateBlogs < ActiveRecord::Migration
  def self.up
    create_table :blogs, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column "title", :string, { :limit => 128, :null => false }
      t.column "description", :text
      t.column "created_at", :datetime, { :null => false }
      t.column "modified_at", :datetime
      t.column "user_id", :integer, { :null => false }
    end
  end

  def self.down
    drop_table :blogs
  end
end
