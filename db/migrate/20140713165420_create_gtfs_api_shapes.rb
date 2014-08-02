class CreateGtfsApiShapes < ActiveRecord::Migration
  def change
    create_table :gtfs_api_shapes, {id: false} do |t|
      t.integer :id  #a shape identified by id has many points
      t.string :io_id
      t.decimal :pt_lat, presence: true, precision: 10, scale: 6
      t.decimal :pt_lon, presence: true, precision: 10, scale: 6
      t.integer :pt_sequence, presence: true, numericability: {only_integer: true, greater_than_or_equal_to: 0}
      t.decimal :dist_traveled, numericability: {greater_than_or_equal_to: 0}
  
      t.timestamps
    end
    add_index :gtfs_api_shapes, :io_id
  end
end
