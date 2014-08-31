require 'test_helper'

module GtfsApi
  class CalendarTest < ActiveSupport::TestCase
    # test "the truth" do
    #   assert true
    # end
    week = ['monday', 'tuesday', 'wednesday','thursday', 'friday', 'saturday', 'sunday']
    
    def self.fill_valid_calendar
      return Calendar.new(
      io_id: 'unique',
      monday: 1,
      tuesday: 1,
      wednesday: 1,
      thursday: 1,
      friday: 1,
      saturday: 1,
      sunday: 1,
      start_date: '2014-07-22',
      end_date: '2014-07-23')
    end
    
    def self.valid_gtfs_feed_calendar 
      {
        service_id: Time.new.to_f.to_s,
        monday: 1,
        tuesday: 1,
        wednesday: 1,
        thursday: 1,
        friday: 1,
        saturday: 1,
        sunday: 1,
        start_date: '2014-07-22',
        end_date: '2014-07-23'
      }
    end
    
    test 'valid calendar' do
      c = CalendarTest.fill_valid_calendar
      assert c.valid?, c.errors.to_a
    end
    
    
    test 'presence of days is required' do
      week.each do |d|
        c = CalendarTest.fill_valid_calendar
        c[d]= nil
        assert c.invalid?
      end
    end
    
    test 'range of values of days' do 
      week.each do |d|
        c = CalendarTest.fill_valid_calendar
        c[d]= 2
        assert c.invalid?
        
        c.errors.clear
        c[d]=Calendar::AVAILABLE
        assert c.valid?, c.errors.to_a
        
        c[d]=0.5
        assert c.invalid?
        
        c.errors.clear
        c[d]=Calendar::NOT_AVAILABLE
        assert c.valid?, c.errors.to_a
        
        c[d]=-1
        assert c.invalid?
      end
    end
    
    test 'start_date presence required' do
      c = CalendarTest.fill_valid_calendar
      c.start_date = nil
      assert c.invalid?
    end  
     
    test 'end_date presence required' do
      c = CalendarTest.fill_valid_calendar
      c.end_date = nil
      assert c.invalid?
    end
    
    # ASSOCIATIONS
    
    
    
    # GTFSABLE IMPORT/EXPORT
    
    test "calendar row can be imported into a Calendar model" do
      model_class = Calendar
      test_class = CalendarTest
      exceptions = [:start_date, :end_date] #exceptions, in test
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
    
    test "a Calendar model can be exported into a gtfs row" do
      model_class = Calendar
      test_class = CalendarTest
      exceptions = [:start_date, :end_date]
      #------ Common_part
      model = test_class.send('fill_valid_' + model_class.to_s.split("::").last.underscore)
      feed_row = model.to_gtfs
      model_class.gtfs_cols.each do |model_attr, feed_col|
        next if exceptions.include? (model_attr)
        assert_equal model.send(model_attr), feed_row[feed_col], "Testing " + model_attr.to_s + " vs " + feed_col.to_s
      end
    end
    
    # Test the exceptions
    test "exceptions start_date and end_date when importing a Calendar model" do
      row = CalendarTest.valid_gtfs_feed_calendar
      model = Calendar.new_from_gtfs(row)
      assert_equal row[:start_date], model.start_date.to_gtfs
      assert_equal row[:end_date], model.end_date.to_gtfs
    end
    
    test "exceptions start_date and end_date when exporting a Calendar model" do
      model = CalendarTest.fill_valid_calendar
      row = model.to_gtfs
      assert_equal model.start_date.to_gtfs, row[:start_date]
      assert_equal model.end_date.to_gtfs, row[:end_date]
    end
    
  end
end
