require 'test_helper'

module GtfsApi
  class CalendarDateTest < ActiveSupport::TestCase
    
    def self.fill_valid_calendar_date 
      return CalendarDate.new(
        io_id: Time.new.to_f.to_s,
        date: '2014-06-10',
        exception_type: CalendarDate::ExceptionTypes[:service_added]
        )
    end
    
    def self.valid_gtfs_feed_calendar_date 
      {
        service_id: Time.new.to_f.to_s,
        date: '2014-06-10',
        exception_type: CalendarDate::SERVICE_ADDED
      }
    end
    
    test "valid calendar date" do
      c = CalendarDateTest.fill_valid_calendar_date
      assert c.valid?, c.errors.to_a
    end
    
    test 'io_id required' do 
      c = CalendarDateTest.fill_valid_calendar_date
      c.io_id = nil
      assert c.invalid?
    end
    
    test 'date required' do
      c = CalendarDateTest.fill_valid_calendar_date
      c.date = nil
      assert c.invalid?
    end
    
    test 'valid exception types' do
      c = CalendarDateTest.fill_valid_calendar_date
      c.exception_type = CalendarDate::ExceptionTypes[:service_added]
      assert c.valid?, c.errors.to_a
      c.exception_type = CalendarDate::ExceptionTypes[:service_removed]
      assert c.valid?, c.errors.to_a
    end
    
    test 'exception_type has to be greater than 0' do
      c = CalendarDateTest.fill_valid_calendar_date
      c.exception_type = 0
      assert c.invalid?
    end
      
    test 'exception_type has to be smaller than 3' do
      c = CalendarDateTest.fill_valid_calendar_date
      c.exception_type = 3
      assert c.invalid?
    end
    
    # ASSOCIATIONS
    
    test 'has many trips' do
      c = CalendarDateTest.fill_valid_calendar_date
      c.save!
      t = TripTest.fill_valid_trip
      t.service_id = c.io_id
      assert t.valid?
      t.save!
      t2 = TripTest.fill_valid_trip
      t2.service_id = c.io_id
      assert t2.valid?
      t2.save!
      assert_equal c.trips.size, Trip.where(service_id: c.io_id).count
      c.trips.each do |trip|
        assert_equal trip.service_id, c.io_id
      end
    end
    
    # IMPORT EXPORT
    
    test "calendar_date row can be imported into a CalendarDate model" do
      model_class = CalendarDate
      test_class = CalendarDateTest
      exceptions = [:date] #exceptions to avoid test
      #--- common part
      feed_row = test_class.send('valid_gtfs_feed_' + model_class.to_s.split("::").last.underscore)
      model = model_class.new_from_gtfs(feed_row)
      assert model.valid?
      model_class.gtfs_cols.each do |model_attr, feed_col|
        next if exceptions.include? (model_attr)
        assert_equal model.send(model_attr), feed_row[feed_col], "Testing " + model_attr.to_s + " vs " + feed_col.to_s
      end
      #------
    end
    
    test "a CalendarDate model can be exported into a gtfs row" do
      model_class = CalendarDate
      test_class = CalendarDateTest
      exceptions = [:date]
      #------ Common_part
      model = test_class.send('fill_valid_' + model_class.to_s.split("::").last.underscore)
      feed_row = model.to_gtfs
      model_class.gtfs_cols.each do |model_attr, feed_col|
        next if exceptions.include? (model_attr)
        assert_equal model.send(model_attr), feed_row[feed_col], "Testing " + model_attr.to_s + " vs " + feed_col.to_s
      end
    end
    
    #test the exception
    test 'date attribute import from gtfs row' do
      row = CalendarDateTest.valid_gtfs_feed_calendar_date
      model = CalendarDate.new_from_gtfs(row)
      assert_equal row[:date], model.date.to_gtfs
    end
    
    test 'date attribute export to gtfs_row' do
      model = CalendarDateTest.fill_valid_calendar_date
      row = model.to_gtfs
      assert_equal model.date.to_gtfs, row[:date]
    end
    
  
  end
end
