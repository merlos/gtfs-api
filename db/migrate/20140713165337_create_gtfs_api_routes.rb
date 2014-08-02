class CreateGtfsApiRoutes < ActiveRecord::Migration
  def change
    create_table :gtfs_api_routes do |t|
      t.string :io_id
      t.belongs_to :agency
      
      t.string :short_name
      t.string :long_name
      t.string :desc
      t.integer :route_type
      t.string :url
      t.string :color
      t.string :text_color

      t.timestamps
    end
    add_index :gtfs_api_routes, :io_id
  end
end
