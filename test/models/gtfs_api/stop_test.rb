require 'test_helper'

module GtfsApi
  class StopTest < ActiveSupport::TestCase  
    # fill a Stop object with valid data
    # no zone and parent_stop is filled
    def self.fill_valid_stop
      return Stop.new(
      io_id: Time.now.to_f.to_s,
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
      s = StopTest.fill_valid_stop
      assert s.valid?
    end
    
    test "stop io_id presence" do
      s = StopTest.fill_valid_stop
      s.io_id = nil
      assert s.invalid?
    end
    
    test "stop name presence" do
      s = StopTest.fill_valid_stop
      s.name = nil
      assert s.invalid?
    end
    
    test "stop lat and long presence and ranges" do
      s = StopTest.fill_valid_stop
      s.lat = nil
      assert s.invalid?
      
      s2 = StopTest.fill_valid_stop
      s2.lon = nil
      assert s2.invalid?
      
      s3 = StopTest.fill_valid_stop
      s3.lat = 91.0
      assert s3.invalid?
      
      s4 = StopTest.fill_valid_stop
      s4.lon = -181.0
      assert s4.invalid?
    end
    
    test "url format" do 
      s = StopTest.fill_valid_stop
      s.url = "http://www.lalala.com"
      assert s.valid?
      s.url = "https://www.lalala.com"
      assert s.valid?
      s.url = "ftp://www.site.com"
      assert s.invalid?
      s2 = StopTest.fill_valid_stop
      s.url = "/home/merlos/caracoles"
      assert s.invalid?
    end
    
    test "location_type range and type is integer" do
      s = StopTest.fill_valid_stop
      s.location_type = 1.1
      assert s.invalid?    
    end
    
    # ASSOCIATION 
    test 'fares_as_origin association works' do
      s = StopTest.fill_valid_stop
      s.zone_id = 'superzone'
      s.save!
      f = FareRuleTest.fill_valid_fare_rule
      f.origin_id = s.zone_id
      f.save!
      assert_equal s.fares_as_origin.size, 1
      assert_equal s.fares_as_origin.first.origin_id, s.zone_id
    end
      
    test 'fares_as_destination association works' do
      s = StopTest.fill_valid_stop
      s.zone_id = 'superzone'
      s.save!
      f = FareRuleTest.fill_valid_fare_rule
      f.destination_id = s.zone_id
      f.save!
      assert_equal s.fares_as_destination.size, 1
      assert_equal s.fares_as_destination.first.destination_id, s.zone_id
    end
    
    test 'fares_is_contained association works' do
      s = StopTest.fill_valid_stop
      s.zone_id = 'superzone'
      s.save!
      f = FareRuleTest.fill_valid_fare_rule
      f.contains_id = s.zone_id
      f.save!
      assert_equal s.fares_is_contained.size, 1
      assert_equal s.fares_is_contained.first.contains_id, s.zone_id
    end
    
    
    #TODO test parent_station
    
  end # class
end # module
