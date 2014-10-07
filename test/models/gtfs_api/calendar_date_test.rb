require 'test_helper'

module GtfsApi
  class CalendarDateTest < ActiveSupport::TestCase
    
    def self.fill_valid_model 
      feed = FeedTest.fill_valid_model
      feed.save!     
      return CalendarDate.new(
        io_id: Time.new.to_f.to_s,
        date: '2014-06-10',
        exception_type: CalendarDate::ExceptionTypes[:service_added],
        feed: feed
        )
    end
    
    def self.valid_gtfs_feed_row 
      {
        service_id: Time.new.to_f.to_s,
        date: '2014-06-10',
        exception_type: CalendarDate::SERVICE_ADDED
      }
    end
    
    def setup 
      @model = CalendarDateTest.fill_valid_model
    end
    
    test "valid calendar date" do
      assert @model.valid?, @model.errors.to_a
    end
    
    test 'io_id required' do 
      @model.io_id = nil
      assert @model.invalid?
    end
    
    test 'date required' do
      @model.date = nil
      assert @model.invalid?
    end
    
    test 'valid exception types' do
      @model.exception_type = CalendarDate::ExceptionTypes[:service_added]
      assert @model.valid?, @model.errors.to_a
      @model.exception_type = CalendarDate::ExceptionTypes[:service_removed]
      assert @model.valid?, @model.errors.to_a
    end
    
    test 'exception_type has to be greater than 0' do
      @model.exception_type = 0
      assert @model.invalid?
    end
      
    test 'exception_type has to be smaller than 3' do
      @model.exception_type = 3
      assert @model.invalid?
    end
    
    test "feed is required" do
      @model.feed = nil
      assert @model.invalid?
    end
    
    # ASSOCIATIONS
    
    test 'has many trips' do
      @model.save!
      t = TripTest.fill_valid_model
      t.service_id = @model.io_id
      assert t.valid?
      t.save!
      t2 = TripTest.fill_valid_model
      t2.service_id = @model.io_id
      assert t2.valid?
      t2.save!
      assert_equal @model.trips.size, Trip.where(service_id: @model.io_id).count
      @model.trips.each do |trip|
        assert_equal trip.service_id, @model.io_id
      end
    end
    
    # IMPORT EXPORT
    
    test "calendar_date row can be imported into a CalendarDate model" do
      model_class = CalendarDate
      test_class = CalendarDateTest
      exceptions = [:date] #exceptions to avoid test
      #--- common part
      feed_row = test_class.valid_gtfs_feed_row
      feed = FeedTest.fill_valid_model
      feed.save!
      model = model_class.new_from_gtfs(feed_row, feed)
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
      model = test_class.fill_valid_model
      feed_row = model.to_gtfs
      model_class.gtfs_cols.each do |model_attr, feed_col|
        next if exceptions.include? (model_attr)
        assert_equal model.send(model_attr), feed_row[feed_col], "Testing " + model_attr.to_s + " vs " + feed_col.to_s
      end
    end
    
    #test the exception
    test 'date attribute import from gtfs row' do
      row = CalendarDateTest.valid_gtfs_feed_row
      feed = FeedTest.fill_valid_model
      feed.save!
      model = CalendarDate.new_from_gtfs(row, feed)
      assert_equal row[:date], model.date.to_gtfs
    end
    
    test 'date attribute export to gtfs_row' do
      row = @model.to_gtfs
      assert_equal @model.date.to_gtfs, row[:date]
    end
    
  
  end
end
