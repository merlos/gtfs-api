class CreateGtfsApiAgencies < ActiveRecord::Migration
  def change
    create_table :gtfs_api_agencies do |t|
      t.string :io_id, limit: 48
      t.string :name
      t.string :url
      t.string :timezone, limit: 64
      t.string :lang, limit:2
      t.string :phone, limit: 24
      t.string :fare_url

      t.timestamps
    end
    add_index :gtfs_api_agencies, :io_id
  end
end
