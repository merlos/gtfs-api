class CreateGtfsApiCalendarDates < ActiveRecord::Migration
  def change
    create_table :gtfs_api_calendar_dates, {id: false} do |t|
      t.integer :id #aka service_id
      t.string :io_id #service_id
      t.date :date
      t.integer :exception_type
      t.timestamps
    end
    add_index :gtfs_api_calendar_dates, :id
    add_index :gtfs_api_calendar_dates, :io_id
  end
end
