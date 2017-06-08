class CategoriesFiller < ActiveRecord::Migration
  def self.up
		add_column :categories, "ordering", :integer, { :null => false, :default => 1 }

		Category.create :name => "All Categories", :short => "all", :ordering => 1
		Category.create :name => "Music", :short => "music", :ordering => 2
		Category.create :name => "Performing Arts", :short => "performing", :ordering => 3
		Category.create :name => "Media", :short => "media", :ordering => 4
		Category.create :name => "Social", :short => "social", :ordering => 5
		Category.create :name => "Education", :short => "education", :ordering => 6
		Category.create :name => "Commercial", :short => "commercial", :ordering => 7
		Category.create :name => "Festivals", :short => "festivals", :ordering => 8
		Category.create :name => "Sports", :short => "sports", :ordering => 9
		Category.create :name => "Visual Arts", :short => "visual", :ordering => 10
		Category.create :name => "Other", :short => "other", :ordering => 11
  end

  def self.down
		remove_column :categories, "ordering"
		Category.delete_all
  end
end
