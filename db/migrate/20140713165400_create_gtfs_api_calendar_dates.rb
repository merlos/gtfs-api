class CreateGtfsApiCalendarDates < ActiveRecord::Migration
  def change
    create_table :gtfs_api_calendar_dates do |t|
      t.string :io_id #service_id
      t.date :date
      t.integer :exception_type
      t.timestamps
    end
    add_index :gtfs_api_calendar_dates, :io_id
  end
end
