class CreateGtfsApiFeedInfos < ActiveRecord::Migration
  def change
    create_table :gtfs_api_feed_infos do |t|
      t.string  :publisher_name, limit:128
      t.string  :publisher_url, limit: 128
      t.string  :lang, limit: 30
      t.date    :start_date
      t.date    :end_date
      t.string  :version, limit: 24
      
      t.timestamps      
      
      #GtfsApi Extensions
      t.string  :io_id, limit: 48
      t.string :name, limit: 128
      
    end
    add_index :gtfs_api_feed_infos, :io_id
  end
end
