class CreateGtfsApiCalendarDates < ActiveRecord::Migration
  def change
    create_table :gtfs_api_calendar_dates do |t|
      t.integer :service_id 
      t.string :io_service_id
      t.date :date
      t.integer :exception_type

      t.timestamps
    end
  end
end
