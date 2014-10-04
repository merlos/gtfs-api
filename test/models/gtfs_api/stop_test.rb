require 'test_helper'

module GtfsApi
  class StopTest < ActiveSupport::TestCase  
    # fill a Stop object with valid data
    # no zone and parent_stop is filled
    def self.fill_valid_model
      feed = FeedTest.fill_valid_model
      feed.save!
   
      return Stop.new(
      io_id: Time.now.to_f.to_s,
      code: 'stop_code',
      name: 'stop_name',
      desc: 'stop_desc',
      lat: 1.1,
      lon: 2.2,
      url: "http://github.com/merlos/",
      location_type: Stop::STOP_TYPE,
      parent_station: nil,
      timezone: 'Madrid/España',
      wheelchair_boarding: 0,
      #Gtfs Extension
      vehicle_type: Stop::VehicleTypes[:tram],
      feed: feed
      )
    end  
    
    def self.valid_gtfs_feed_row
      return {
        stop_id: "stop_" + Time.now.to_f.to_s,
        stop_code: 'stop_code',
        stop_name: 'stop_name',
        stop_desc: 'stop_desc',
        stop_lat: '1.1',
        stop_lon: '2.2',
        zone_id: "zone",
        stop_url: "http://github.com/merlos/",
        location_type: "0",
        parent_station: nil,
        stop_timezone: 'Madrid/España',
        wheelchair_boarding: '0',
        #Gtfs Extension
        vehicle_type: '100'
        
      }
    end
    
    def setup 
      @model = StopTest.fill_valid_model
    end
    
    test "valid stop" do
      assert @model.valid?
    end
    
    test "stop io_id presence" do
      @model.io_id = nil
      assert @model.invalid?
    end
    
    test "stop name presence" do
      @model.name = nil
      assert @model.invalid?
    end
    
    test "stop lat and long presence and ranges" do
      @model.lat = nil
      assert @model.invalid?
      
      s2 = StopTest.fill_valid_model
      s2.lon = nil
      assert s2.invalid?
      
      s3 = StopTest.fill_valid_model
      s3.lat = 91.0
      assert s3.invalid?
      
      s4 = StopTest.fill_valid_model
      s4.lon = -181.0
      assert s4.invalid?
    end
    
    test "url format" do 
      @model.url = "http://www.lalala.com"
      assert @model.valid?
      @model.url = "https://www.lalala.com"
      assert @model.valid?
      @model.url = "ftp://www.site.com"
      assert @model.invalid?
      model2 = StopTest.fill_valid_model
      model2.url = "/home/merlos/caracoles"
      assert model2.invalid?
    end
    
    test "location_type upper limit is 2" do
      @model.location_type = 3
      assert @model.invalid?    
    end
    
    test "wheelchair_boarding has to be integer" do
      @model.wheelchair_boarding = 1.1
      assert @model.invalid?
    end
    
    test "wheelchair_boarding has to be positive" do
      @model.wheelchair_boarding = -1
      assert @model.invalid?
    end
    
    test "wheelchair_boarding has to be 0 or 1" do
      @model.wheelchair_boarding = 0
      assert @model.valid?
      @model.wheelchair_boarding = 1
      assert @model.valid?
      @model.wheelchair_boarding = 2
      assert @model.invalid?
    end
   
    
    # Vehicle type
    test "vehicle_type out of upper limit is invalid" do
      @model.vehicle_type = 1703 # valid range is [0..1703]
      assert @model.invalid?
    end
    
    test "vehicle_type has to be positive" do
      @model.vehicle_type = -1
      assert @model.invalid?
    end
  
    test "vehicle_type has to be in VehicleTypes constant" do
       @model.vehicle_type = 1250
       assert @model.invalid?
       assert (@model.errors.added? :vehicle_type, :invalid)
    end
    
    test "url is optional" do
      @model.url = nil
      assert @model.valid?
    end
    
    # ASSOCIATION 
    test 'fares_as_origin association works' do
      @model.zone_id = 'superzone'
      @model.save!
      f = FareRuleTest.fill_valid_model
      f.origin_id = @model.zone_id
      f.save!
      assert_equal @model.fares_as_origin.size, 1
      assert_equal @model.fares_as_origin.first.origin_id, @model.zone_id
    end
      
    test 'fares_as_destination association works' do
      @model.zone_id = 'superzone'
      @model.save!
      f = FareRuleTest.fill_valid_model
      f.destination_id = @model.zone_id
      f.save!
      assert_equal @model.fares_as_destination.size, 1
      assert_equal @model.fares_as_destination.first.destination_id, @model.zone_id
    end
    
    test 'fares_is_contained association works' do
      @model.zone_id = 'superzone'
      @model.save!
      f = FareRuleTest.fill_valid_model
      f.contains_id = @model.zone_id
      f.save!
      assert_equal @model.fares_is_contained.size, 1
      assert_equal @model.fares_is_contained.first.contains_id, @model.zone_id
    end
    
    
    #TODO test parent_station
    
    
    # GTFSABLE tests
    
    test "stop row can be imported into a Stop model" do
       model_class = Stop
       test_class = StopTest
       exceptions = [] #exceptions, in test
       #--- common part
       feed_row = test_class.valid_gtfs_feed_row
       #puts feed_row
       model = model_class.new_from_gtfs(feed_row)
       assert model.valid?
       model_class.gtfs_cols.each do |model_attr, feed_col|
         next if exceptions.include? (model_attr)
         model_value = model.send(model_attr)
         model_value = model_value.to_s if model_value.is_a? Numeric
         assert_equal feed_row[feed_col], model_value, "Testing " + model_attr.to_s + " vs " + feed_col.to_s
       end
       #------
     end
   
     test "a Stop model can be exported into a gtfs row" do
       model_class = Stop
       test_class = StopTest
       exceptions = []
       #------ Common_part
       model = test_class.fill_valid_model
       feed_row = model.to_gtfs
       #puts feed_row
       model_class.gtfs_cols.each do |model_attr, feed_col|
         next if exceptions.include? (model_attr)
         feed_value = feed_row[feed_col]
         feed_value = feed_value.to_f if model.send(model_attr).is_a? Numeric
         assert_equal model.send(model_attr), feed_value, "Testing " + model_attr.to_s + " vs " + feed_col.to_s
       end
     end
     
     test "a stop row that belongs to a station can be imported into a gtfs row" do
       
     end
    
    
     test "a Stop model that belongs to a station can be exported" do
       
     end
    
    
  end # class
end # module
