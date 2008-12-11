class AddPopularity < ActiveRecord::Migration
  def self.up
    add_column :events, "popularity", :integer, { :null => false, :default => 0}
  end

  def self.down
    remove_column :events, "popularity"
  end
end
