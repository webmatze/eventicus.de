class RemoveComments < ActiveRecord::Migration
  def self.up
    drop_table :comments
  end
  
  def self.down
    create_table :comments, :force => true do |t|
      t.column :title, :string, :limit => 50, :default => ""
      t.column :comment, :string, :default => ""
      t.column :commentable_id, :integer, :default => 0, :null => false
      t.column :commentable_type, :string, :limit => 15, :default => "", :null => false
      t.column :user_id, :integer, :default => 0, :null => false
      t.timestamps
    end
    
    add_index :comments, ["user_id"], :name => "fk_comments_user"
  end
end
