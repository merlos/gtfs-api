require 'test_helper'

module GtfsApi::Concerns::Models::Concerns
  
  class TestSetGtfsRow 
    include GtfsApi::Concerns::Models::Concerns::Gtfsable
    #gtfs feed columns definitions
    set_gtfs_col :io_id 
    set_gtfs_col :default_col_map
    set_gtfs_col :test1, :test2
  end
  
  class OverrideId 
    include GtfsApi::Concerns::Models::Concerns::Gtfsable
    #gtfs feed columns definitions
    set_gtfs_col :io_id, :override_id 
  end
  
  
  class CsvableTest < ActiveSupport::TestCase
    
    test "io_id is automatically converted into classname_id" do
      c = TestSetGtfsRow.gtfs_cols
      assert c[:io_id] == :io_id
    end
    
    test "default mapping" do
      assert TestSetGtfsRow.gtfs_cols[:default_col_map] == :default_col_map
    end
    
    test "overriding default mapping" do
      assert TestSetGtfsRow.gtfs_cols[:test1] == :test2
    end
    
    test "override io_id works" do
      assert OverrideId.gtfs_cols[:io_id] == :override_id
    end
    
    #
    # NOW Let's check this out with real classes
    # 
    # this test assumes that GtfsApi::Agency isCsvable
    test "io_id works and that removes the name" do
      csv_row = {:agency_id => 'agency_id', :agency_name=>'agency_name'}
      a = GtfsApi::Agency.new_from_gtfs_feed(csv_row)
      assert(a.io_id == 'agency_id')
      assert(a.name == 'agency_name')
    end
    
    #
    # this test assumes that GtfsApi::Route is Csvable
    test "that type is an exception" do
      csv_row = {:route_type=>1}
      assert_nothing_raised (ActiveRecord::UnknownAttributeError) { GtfsApi::Route.new_from_gtfs_feed(csv_row)}
    end
    
    # this test assumes that GtfsApi::Route is Csvable
    # and that that the model includes this line 
    # set_gtfs_col :io_id
    # set_gtfs_col :route_type, :route_type
    test "that set_gtfs_col works with io_id" do
      c = GtfsApi::Route.gtfs_cols
      #io_id is converted into classname + _ +
      assert c[:io_id] == :route_id
    end  
    # this test assumes that GtfsApi::Route is Csvable
    # and that that the model includes this line 
    # set_gtfs_col :route_type, :route_type
    test "that set_gtfs_col works with two arguments" do
      c = GtfsApi::Route.gtfs_cols
      assert c[:route_type] == :route_type 
    end
    
    # CalendarDate is Csvable
    # set_csv_col 
    # default io_id to is override
    test "that set_csv_col io_id is overriden setting a second argument" do
      c =  GtfsApi::CalendarDate.gtfs_cols
      assert c[:io_id] == :service_id
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