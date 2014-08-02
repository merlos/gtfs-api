class CreateGtfsApiAgencies < ActiveRecord::Migration
  def change
    create_table :gtfs_api_agencies do |t|
      t.string :io_id
      t.string :name
      t.string :url
      t.string :timezone
      t.string :lang
      t.string :phone
      t.string :fare_url

      t.timestamps
    end
    add_index :gtfs_api_agencies, :io_id
  end
end
