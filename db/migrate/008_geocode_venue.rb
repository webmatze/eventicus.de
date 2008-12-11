class GeocodeVenue < ActiveRecord::Migration
  def self.up
    add_column :locations, "lat", :decimal, :precision => 15, :scale => 10
    add_column :locations, "lng", :decimal, :precision => 15, :scale => 10
  end

  def self.down
    remove_column :locations, "lat"
    remove_column :locations, "lng"
  end
end
