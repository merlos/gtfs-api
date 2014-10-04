require 'test_helper'

module GtfsApi
  class FrequencyTest < ActiveSupport::TestCase
    
    def self.fill_valid_model
      trip = TripTest.fill_valid_model
      feed = FeedTest.fill_valid_model
      feed.save!
      return Frequency.new(
      trip: trip,
      start_time: "14:00:21", 
      end_time: "15:00:22",
      headway_secs: 1000,
      exact_times: 0,
      feed: feed)
    end
    
    def self.valid_gtfs_feed_row
      trip = TripTest.fill_valid_model
      trip.save!
      {
       trip_id: trip.io_id,
       start_time: "14:00:21", 
       end_time: "24:00:11",
       headway_secs: "1000",
       exact_times: "0"
      }
    end
    
    def setup 
      @model = FrequencyTest.fill_valid_model
    end
    
    test "valid frequency" do
      assert @model.valid?, @model.errors.to_a
    end
   
    test "trip_id required" do
      @model.trip = nil
      assert @model.invalid?
    end
   
    test "start_time required" do
      @model.start_time = nil
      assert @model.invalid?
    end
   
    test "end_time required" do
     @model.end_time = nil
     assert @model.invalid?
    end
   
    test "headway_secs required" do
     @model.headway_secs = nil
     assert @model.invalid?
    end

    test "headway_secs has to be positive" do
     @model.headway_secs = -1
     assert @model.invalid?
   end
   
   test 'headway_secs has to be integer' do
     @model.headway_secs = 1.1
     assert @model.invalid?
    end
    
    test "exact_times can be nil" do
      @model.exact_times = nil 
      assert @model.valid?
    end
    
    test "exact_times has to be integer" do
      @model.exact_times = 0.5 
      assert @model.invalid?
    end
    
    test "exact_time not_exact value is valid" do  
      @model.exact_times = Frequency::NOT_EXACT   
      assert @model.valid?, @model.errors.to_a
    end
    
    test "exact_times cannot be negative" do
      @model.exact_times = -1 
      assert @model.invalid?
    end
       
    test "exact_times exact is a valid value" do
      @model.exact_times = Frequency::EXACT
      assert @model.valid?, @model.errors.to_a
    end
    
    test "eact_times greater than 1 is not valid" do  
      @model.exact_times = 2
      assert @model.invalid? 
    end
    
    test "virtual attribute trip_io_id sets and gets trip" do
      t = TripTest.fill_valid_model
      assert t.valid?
      t.save!
      
      @model.trip = nil
      assert_equal @model.trip, nil 
      assert_equal @model.trip_io_id, nil 
      @model.trip_io_id = t.io_id 
      assert_equal @model.trip.io_id, t.io_id
      assert_equal @model.trip_io_id, t.io_id
      assert t.valid?
    end
    
    test "not valid when virtual attribute trio_io_id not found" do
       @model.trip_io_id = "this_trip_does_not_exist"
       assert @model.invalid?
    end
    
   # IMPORT/EXPORT
   
   test "frequency row can be imported into a Frequency model" do
      model_class = Frequency
      test_class = FrequencyTest
      exceptions = [] #exceptions, in test
      #--- common part
      feed_row = test_class.valid_gtfs_feed_row
      #puts feed_row
      model = model_class.new_from_gtfs(feed_row)
      assert model.valid?, model.errors.to_a.to_s
      
      model_class.gtfs_cols.each do |model_attr, feed_col|
        next if exceptions.include? (model_attr)
        model_value = model.send(model_attr)
        model_value = model_value.to_s if model_value.is_a? Numeric
        model_value = model_value.to_gtfs if model_value.is_a? Time
        assert_equal feed_row[feed_col], model_value, "Testing " + model_attr.to_s + " vs " + feed_col.to_s
      end
      #------
    end
  
    test "a Frequency model can be exported into a gtfs row" do
      model_class = Frequency
      test_class = FrequencyTest
      exceptions = []
      #------ Common_part
      model = test_class.fill_valid_model
      feed_row = model.to_gtfs
      #puts feed_row
      model_class.gtfs_cols.each do |model_attr, feed_col|
        next if exceptions.include? (model_attr)
        feed_value = feed_row[feed_col]
        feed_value = feed_value.to_f if model.send(model_attr).is_a? Numeric
        feed_value = Time.new_from_gtfs(feed_value) if model.send(model_attr).is_a? Time
        assert_equal model.send(model_attr), feed_value, "Testing " + model_attr.to_s + " vs " + feed_col.to_s
      end
    end 
    
 
    
  end
end
