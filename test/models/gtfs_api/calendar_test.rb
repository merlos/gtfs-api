require 'test_helper'

module GtfsApi
  class CalendarTest < ActiveSupport::TestCase
    # test "the truth" do
    #   assert true
    # end
    week = ['monday', 'tuesday', 'wednesday','thursday', 'friday', 'saturday', 'sunday']
    
    def fill_valid_calendar
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
    
    test 'valid calendar' do
      c = self.fill_valid_calendar
      assert c.valid?, c.errors.to_a
    end
    
    
    test 'presence of days is required' do
      week.each do |d|
        c = self.fill_valid_calendar
        c[d]= nil
        assert c.invalid?
      end
    end
    
    test 'range of values of days' do 
      week.each do |d|
        c = self.fill_valid_calendar
        c[d]= 2
        assert c.invalid?
        
        c.errors.clear
        c[d]=Calendar::SERVICE_AVAILABLE
        assert c.valid?, c.errors.to_a
        
        c[d]=0.5
        assert c.invalid?
        
        c.errors.clear
        c[d]=Calendar::SERVICE_NOT_AVAILABLE
        assert c.valid?, c.errors.to_a
        
        c[d]=-1
        assert c.invalid?
      end
    end
    
    test 'start_date presence required' do
      c = self.fill_valid_calendar
      c.start_date = nil
      assert c.invalid?
    end  
     
    test 'end_date presence required' do
      c = self.fill_valid_calendar
      c.end_date = nil
      assert c.invalid?
    end
    
  end
end
