class CreateGtfsApiTransfers < ActiveRecord::Migration
  def change
    create_table :gtfs_api_transfers do |t|
      t.string :io_from_stop_id
      t.string :io_to_stop_id
      
      t.belongs_to :from_stop
      t.belongs_to :to_stop
      
      t.integer :transfer_type
      t.integer :min_transfer_time

      t.timestamps
    end
    add_index :gtfs_api_transfers, :from_stop_id
    add_index :gtfs_api_transfers, :to_stop_id
  end
end
