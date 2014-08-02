require 'test_helper'

module GtfsApi
  class StopTest < ActiveSupport::TestCase
    # test "the truth" do
    #   assert true
    # end
    
    # fill a Stop object with valid data
    # no zone and parent_stop is filled
    def fill_valid_stop
      return Stop.new(
      io_id: '_stop_id',
      code: 'stop_code',
      name: 'stop_name',
      desc: 'stop_desc',
      lat: 1.1,
      lon: 2.2,
      url: "http://github.com/merlos/",
      location_type: Stop::STOP_TYPE,
      )
    end  
    
    test "valid stop" do
      s = self.fill_valid_stop
      assert s.valid?
    end
    
    test "stop io_id presence" do
      s = self.fill_valid_stop
      s.io_id = nil
      assert s.invalid?
    end
    
    test "stop name presence" do
      s = self.fill_valid_stop
      s.name = nil
      assert s.invalid?
    end
    
    test "stop lat and long presence and ranges" do
      s = self.fill_valid_stop
      s.lat = nil
      assert s.invalid?
      
      s2 = self.fill_valid_stop
      s2.lon = nil
      assert s2.invalid?
      
      s3 = self.fill_valid_stop
      s3.lat = 91.0
      assert s3.invalid?
      
      s4 = self.fill_valid_stop
      s4.lon = -181.0
      assert s4.invalid?
    end
    
    test "location_type range and type is integer" do
      s2 = self.fill_valid_stop
      s2.location_type = 2
  
      s = self.fill_valid_stop
      s.location_type = 1.1
      assert s.invalid?    
    end
    
    #TODO test belongs_to zone
    #TODO tes parent_station
    
  end # class
end # module
