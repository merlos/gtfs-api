class CreateGtfsApiFrequencies < ActiveRecord::Migration
  def change
    create_table :gtfs_api_frequencies do |t|
      t.integer :trip_id
      t.time :start_time
      t.time :end_time
      t.integer :headway_secs
      t.integer :exact_times

      t.timestamps
    end
    add_index :gtfs_api_frequencies, :trip_id
  end
end
