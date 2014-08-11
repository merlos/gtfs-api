require 'test_helper'

module GtfsApi
  class CalendarDateTest < ActiveSupport::TestCase
    # test "the truth" do
    #   assert true
    # end
    
    def fill_valid_calendar_date 
      return CalendarDate.new(
        id: 1,
        io_id: 'calendar_one',
        date: '2014-06-10',
        exception_type: CalendarDate::SERVICE_ADDED
        )
    end
    
    test "valid calendar date" do
      c = self.fill_valid_calendar_date
      assert c.valid?, c.errors.to_a
    end
    
    test 'id required' do
      c = self.fill_valid_calendar_date
      c.id = nil
      assert c.invalid? 
    end
    
    test 'io_id required' do 
      c = self.fill_valid_calendar_date
      c.io_id = nil
      assert c.invalid?
    end
    
    test 'date required' do
      c = self.fill_valid_calendar_date
      c.date = nil
      assert c.invalid?
    end
    
    test 'exception type range' do
      c = self.fill_valid_calendar_date
      c.exception_type = CalendarDate::SERVICE_ADDED
      assert c.valid?, c.errors.to_a
      c.exception_type = CalendarDate::SERVICE_REMOVED
      assert c.valid?, c.errors.to_a
      
      #test out of range
      c.exception_type = 0
      assert c.invalid?
      
      c.errors.clear
      c.exception_type= CalendarDate::SERVICE_ADDED
      assert c.valid?, c.errors.to_a
      c.exception_type = 3
      assert c.invalid?
      
    end
    
    # ASSOCIATIONS
    
    
  end
end
