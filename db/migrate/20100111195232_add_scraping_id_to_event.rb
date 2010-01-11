class AddScrapingIdToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :scrapingid, :string
  end

  def self.down
    remove_column :events, :scrapingid
  end
end
