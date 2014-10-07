require 'test_helper'

module GtfsApi::Io::Models::Concerns
  
  # SUPPORT CLASSES
  
  # empty col assignment
  class GtfsableTestEmptyMapping
    include GtfsApi::Io::Models::Concerns::Gtfsable
  end
  
  # mapping
  class GtfsableTestMapping
  include GtfsApi::Io::Models::Concerns::Gtfsable
    #gtfs feed columns definitions
    set_gtfs_file :forced_name
    set_gtfs_col :default_map
    set_gtfs_col :gtfs_model, :gtfs_feed
    
    def initialize 
      @attributes = {}
    end
    
    def initialize(hash = {})
      @attributes = {}
      hash.each do |key, val|
        @attributes[key] = val
      end
    end
    
    def default_map=(val) 
      @attributes[:default_map] = val 
    end
    def default_map 
      @attributes[:default_map]
    end
    
    def gtfs_model=(val) 
      @attributes[:gtfs_model] = val 
    end
    def gtfs_model 
      @attributes[:gtfs_model]
    end
  end
  
  # after rehash
  class GtfsableTestAfterRehash
    include GtfsApi::Io::Models::Concerns::Gtfsable
     set_gtfs_col :io_id
    #setters and getters of attributtes
    def io_id=(val) 
      @io_id = val 
    end
    def io_id 
      @io_id 
    end
    # overrides the value of io_id when exporting to gtfs
    def after_rehash_to_gtfs(gtfs_feed_row)
      gtfs_feed_row[:io_id] = "after_rehash_was_called"
      return gtfs_feed_row
    end
    
  end
  
  # time and date setters
  class GtfsTimeSetterTest
    include ActiveRecord::Validations
    include GtfsApi::Io::Models::Concerns::Gtfsable
    #gtfs feed columns definitions
    set_gtfs_col :sample_time
    set_gtfs_col :sample_date
    
    def initialize
      @attribute_tmp = {}
    end
    
    #fake write attribute to test
    # TODO think a better solution
    # this method is called within gtfs_time_setter
    def write_attribute(symbol, val)
      @attribute_tmp[symbol] = val
    end
    
    def sample_time=(val)
      gtfs_time_setter(:sample_time, val)
    end
    def sample_time
      @attribute_tmp[:sample_time]
    end
    
    
    def sample_date=(val)
      @attribute_tmp[:sample_date] = val
    end
    def sample_date
      @attribute_tmp[:sample_date]
    end
  end
  
  class GtfsableTest < ActiveSupport::TestCase
     
    test "gtfs_cols returns nil when no mapping defined" do
      assert_nil GtfsableTestEmptyMapping.gtfs_cols
    end
    test "gtfs_attr returns nil when no mapping defined" do
        assert_nil GtfsableTestEmptyMapping.gtfs_attr
    end
         
    test "to_gtfs returns a hash with no cols mapping" do
      c = GtfsableTestEmptyMapping.new
      assert_empty c.to_gtfs
    end
    
    
    test "gtfs_file returns the pluralized uderscore class name when not set" do
      assert_equal :gtfsable_test_empty_mappings, GtfsableTestEmptyMapping.gtfs_file
    end
    
    test "gtfs_filename returns the pluralized underscore class name adding .txt when not set" do
      assert_equal 'gtfsable_test_empty_mappings.txt', GtfsableTestEmptyMapping.gtfs_filename
    end
    
    test "default set_col_map with no second argument are equal" do
      assert_equal :default_map, GtfsableTestMapping.gtfs_cols[:default_map]
    end
    
    test "set_col_map maps to the second argument when set" do
      assert_equal :gtfs_feed, GtfsableTestMapping.gtfs_cols[:gtfs_model]
    end
    
    test "gfts_file returns the name set by set_gtfs_file linked to the class" do
      assert_equal :forced_name, GtfsableTestMapping.gtfs_file
    end
    
    test "gtfs_filename returns the name set by set_gtfs_file" do
      assert_equal 'forced_name.txt', GtfsableTestMapping.gtfs_filename
    end
    
    test "to_gtfs returns a hash" do
      c = GtfsableTestMapping.new
      c.default_map = "hola"
      c.gtfs_model = "adios"
      gtfs = c.to_gtfs
      assert_kind_of Hash, gtfs
    end
    
    test "to_gtfs returns THE expected hash" do
      c = GtfsableTestMapping.new
      c.default_map = "hola"
      gtfs_feed_hash = c.to_gtfs
      assert_equal 'hola', gtfs_feed_hash[:default_map]
    end
    
    test "to_gtfs calls after_rehash_to_gtfs" do
      c = GtfsableTestAfterRehash.new
      c.io_id = "hola"
      gtfs = c.to_gtfs
      assert_equal "after_rehash_was_called", gtfs[:io_id]
    end
    
    test "gtfs_col_for_attr returns the name of the col" do
       assert_equal :default_map , GtfsableTestMapping.gtfs_col_for_attr(:default_map)
       assert_equal :gtfs_feed , GtfsableTestMapping.gtfs_col_for_attr(:gtfs_model)
    end
       
    test "gtfs_time_setter sets a time with a time with trailing 0" do
      t = GtfsTimeSetterTest.new
      t.sample_time = "09:44:45" #without 0
      assert Time.new(0,1,1,9,55,33,'+00:00'), t.sample_time
    end   
    
    test 'gtfs_time_setter sets a time with hours large than 25' do
      t = GtfsTimeSetterTest.new
      t.sample_time = "29:55:55" # 1d + 5h 55m 55s
      assert_equal Time.new(0000,01,02,5,55,55,'+00:00'), t.sample_time # 0000-01-02 5:55:55 +0000
    end
        
    test "to_gtfs returns date attributes in the gtfs format" do
      t = GtfsTimeSetterTest.new
      t.sample_date = Date.new(2014,06,20)
      gtfs_row = t.to_gtfs #io_id is like any other field in this fake model
      assert_equal '2014-06-20', gtfs_row[:sample_date]
    end
    
    test "to_gtfs returns times in the gtfs format" do
      c = GtfsTimeSetterTest.new
      c.sample_time = Time.new(0000,01,02,5,55,55,'+00:00')
      gtfs_row = c.to_gtfs #io_id is like any other field in this fake model
      assert_equal "29:55:55" , gtfs_row[:sample_time]
    end
    
    
    test "new_from_gtfs assigns the values to the attributes" do
      gtfs_feed_row = {default_map: 'value1', gtfs_feed: 'value2'}
      c = GtfsableTestMapping.new_from_gtfs(gtfs_feed_row)
      assert_equal 'value1', c.default_map
      assert_equal 'value2', c.gtfs_model
    end
    
    test "new_from_gtfs ignores those values not included" do
      gtfs_feed_row = {default_map: 'value1', gtfs_feed: 'value2', caca:''}
      assert_nothing_raised do 
        c = GtfsableTestMapping.new_from_gtfs(gtfs_feed_row)
        assert_equal 'value1', c.default_map
        assert_equal 'value2', c.gtfs_model
      end
    end
    
    ##
    # These tests make the concern dependent on models of gtfsapi
    # TESTS WITH REAL MODELS
    ##
    # 
    # this test assumes there is a Route model that does not have
    # the attribute not_attribute
    test "new_from_gtfs does not launc attribute not found when an attributed does not exist" do
      assert_nothing_raised do
        GtfsApi::Route.new_from_gtfs({not_attribute: 'caca'})
      end
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