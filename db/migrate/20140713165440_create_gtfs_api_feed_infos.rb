class CreateGtfsApiFeedInfos < ActiveRecord::Migration
  def change
    create_table :gtfs_api_feed_infos do |t|
      t.string  :publisher_name, limit:128
      t.string  :publisher_url, limit: 128
      t.string  :lang, limit: 30
      t.date    :start_date
      t.date    :end_date
      t.string  :version, limit: 24
      
      #GtfsApi Extensions
      t.string  :io_id
      t.integer :data_version, default: 1 #version control for incremental updates    
      t.timestamps
    end
    add_index :gtfs_api_feed_infos, :io_id
  end
end
