class CreateGtfsApiFareAttributes < ActiveRecord::Migration
  def change
    create_table :gtfs_api_fare_attributes do |t|
      t.string :io_id
      t.decimal :price
      t.string :currency_type
      t.integer :payment_method
      t.integer :transfers
      t.integer :transfer_duration

      t.timestamps
    end
  end
  
end
