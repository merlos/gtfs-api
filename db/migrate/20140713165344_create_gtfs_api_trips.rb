class CreateGtfsApiTrips < ActiveRecord::Migration
  def change
    create_table :gtfs_api_trips do |t|
      t.string :io_id
      t.belongs_to :route
      
      t.integer :service_id
      t.string :headsign
      t.string :short_name
      
      t.integer :direction_id #boolean
      
      t.string :block_id
      t.integer :shape_id
      
      t.integer :wheelchair_accesible
      t.integer :bikes_allowed

      t.timestamps
    end
    add_index :gtfs_api_trips, :io_id, unique: true
    add_index :gtfs_api_trips, :block_id
    add_index :gtfs_api_trips, :shape_id
    
  end
end
