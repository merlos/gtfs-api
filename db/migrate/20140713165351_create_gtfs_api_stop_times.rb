class CreateGtfsApiStopTimes < ActiveRecord::Migration
  def change
    create_table :gtfs_api_stop_times do |t|
      t.integer :trip_id
      t.time :arrival_time
      t.time :departure_time
      t.integer :stop_id
      t.integer :stop_sequence
      t.string :stop_headsign
      t.integer :pickup_type
      t.integer :drop_off_type
      t.decimal :shape_dist_traveled

      t.timestamps
    end
  end
end
