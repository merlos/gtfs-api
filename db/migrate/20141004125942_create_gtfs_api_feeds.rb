class CreateGtfsApiFeeds < ActiveRecord::Migration
  def change
    create_table :gtfs_api_feeds do |t|
      t.string :name
      t.string :url
      t.string :prefix
      t.integer :version
    
      t.timestamps
    end
  end
end
