class CreateGtfsApiFeeds < ActiveRecord::Migration
  def change
    create_table :gtfs_api_feeds do |t|
      t.string :name
      t.string :url
      t.integer :version
      t.string :prefix

      t.timestamps
    end
  end
end
