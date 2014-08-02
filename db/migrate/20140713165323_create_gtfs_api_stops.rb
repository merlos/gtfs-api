class CreateGtfsApiStops < ActiveRecord::Migration
  def change
    create_table :gtfs_api_stops do |t|
      t.string :io_id
      t.string :code
      t.string :name
      t.string :desc
      t.decimal :lat, precision: 10, scale: 6
      t.decimal :lon, precision: 10, scale: 6
      
      t.string :zone_id, null:true #=> fare rules, 
      
      t.string :url
      t.integer :location_type
      
      t.string :io_parent_station, null:true
      t.belongs_to :parent_station, null:true
      
      t.string :timezone
      t.integer :wheelchair_boarding

      t.timestamps
    end
    add_index :gtfs_api_stops, :io_id
    add_index :gtfs_api_stops, :zone_id
    
  end
end
