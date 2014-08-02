class CreateGtfsApiFeedInfos < ActiveRecord::Migration
  def change
    create_table :gtfs_api_feed_infos do |t|
      t.string :feed_publisher_name
      t.string :feed_publisher_url
      t.string :feed_lang
      t.date :feed_start_date
      t.date :feed_end_date
      t.string :feed_version

      t.timestamps
    end
  end
end
