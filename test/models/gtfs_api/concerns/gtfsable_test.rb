require 'test_helper'

module GtfsApi::Concerns::Models::Concerns
  
  #Support class for test that implements gtfsable
  class GtfsableTestSupport1 
    include GtfsApi::Concerns::Models::Concerns::Gtfsable
    #gtfs feed columns definitions
    set_gtfs_col :io_id 
    set_gtfs_col :default_col_map
    set_gtfs_col :test1, :test2
    
    #setters and getters of attributtes
    def io_id=(val) 
      @io_id = val 
    end
    def io_id 
      @io_id 
    end
  
    def default_col_map=(val) 
      @default_col_map = val 
    end
    def default_col_map 
      @default_col_map 
    end
    
    def test1=(val) 
      @test1 = val 
    end
    def test1 
      @test1 
    end
    
    # overrides the value of io_id when exporting to gtfs
    def after_rehash_to_gtfs(gtfs_feed_row)
      gtfs_feed_row[:io_id] = "after_rehash_was_called"
      return gtfs_feed_row
    end
    
  end
  
  #Support class for test that implements gtfsable
  class OverrideId 
    include GtfsApi::Concerns::Models::Concerns::Gtfsable
    #gtfs feed columns definitions
    set_gtfs_col :io_id, :override_id 
    
    @io_id
  
    def io_id=(val) 
      @io_id = val 
    end
    def io_id 
      @io_id 
    end
  end
  
  
  class GtfsableTest < ActiveSupport::TestCase
    
    test "io_id is automatically converted into classname_id" do
      c = GtfsableTestSupport1.gtfs_cols
      assert c[:io_id] == :io_id
    end
    
    test "default mapping" do
      assert GtfsableTestSupport1.gtfs_cols[:default_col_map] == :default_col_map
    end
    
    test "overriding default mapping" do
      assert GtfsableTestSupport1.gtfs_cols[:test1] == :test2
    end
    
    test "to_gtfs returns a hash" do
      c = OverrideId.new
      c.io_id = "hola"
      gtfs = c.to_gtfs
      assert_kind_of Hash, gtfs
    end
    
    test "to_gtfs returns THE expected hash" do
      c = OverrideId.new
      c.io_id = "hola"
      gtfs = c.to_gtfs
      assert_equal 'hola', gtfs[:override_id]
    end
    
    test "to_gtfs calls after_rehash_to_gtfs" do
      c = GtfsableTestSupport1.new
      c.io_id = "hola"
      gtfs = c.to_gtfs
      assert_equal "after_rehash_was_called", gtfs[:io_id]
    end
    
    test "gtfs_col_for_attr returns the name of the col" do
       assert_equal :io_id , GtfsableTestSupport1.gtfs_col_for_attr(:io_id)
       assert_equal :test2 , GtfsableTestSupport1.gtfs_col_for_attr(:test1)
    end
       
              
    # this test assumes that GtfsApi::Route is gtfsable
    # and that that the model includes this line 
    # set_gtfs_col :io_id
    # set_gtfs_col :route_type, :route_type
    test "that set_gtfs_col works with io_id" do
      c = GtfsApi::Route.gtfs_cols
      #io_id is converted into classname + _ +
      assert c[:io_id] == :route_id
    end  
    # this test assumes that GtfsApi::Route is gtfsable
    # and that that the model includes this line 
    # set_gtfs_col :route_type, :route_type
    test "that set_gtfs_col works with two arguments" do
      c = GtfsApi::Route.gtfs_cols
      assert c[:route_type] == :route_type 
    end
    
    # CalendarDate is gsvable
    # set_csv_col 
    # default io_id to is overriden
    test "that set_csv_col io_id is overriden setting a second argument" do
      gtfs_cols =  GtfsApi::CalendarDate.gtfs_cols
      assert gtfs_cols[:io_id] == :service_id
    end
    
  
    test "file names for all classes are the ones defined in GTFS feed specification" do
      assert_equal GtfsApi::Agency.gtfs_file, :agency
      assert_equal GtfsApi::Stop.gtfs_file, :stops
      assert_equal GtfsApi::Route.gtfs_file, :routes
      assert_equal GtfsApi::Trip.gtfs_file, :trips
      assert_equal GtfsApi::StopTime.gtfs_file, :stop_times
      assert_equal GtfsApi::Calendar.gtfs_file, :calendar
      assert_equal GtfsApi::CalendarDate.gtfs_file, :calendar_dates
      assert_equal GtfsApi::FareAttribute.gtfs_file, :fare_attributes
      assert_equal GtfsApi::FareRule.gtfs_file, :fare_rules
      assert_equal GtfsApi::Shape.gtfs_file, :shapes
      assert_equal GtfsApi::Frequency.gtfs_file, :frequencies
      assert_equal GtfsApi::Transfer.gtfs_file, :transfers
      assert_equal GtfsApi::FeedInfo.gtfs_file, :feed_info
    end
    
  end
end