require 'test_helper'

module GtfsApi
  class FrequencyTest < ActiveSupport::TestCase
    
    def self.fill_valid_frequency
      trip = Trip.find_by_io_id('_trip_one') 
      return Frequency.new(
      trip: trip,
      start_time: "14:00:21", 
      end_time: "15:00:22",
      headway_secs: 1000,
      exact_times: 0)
    end
    
    def self.valid_gtfs_feed_frequency
      trip = TripTest.fill_valid_trip
      trip.save!
      {
       trip_id: trip.io_id,
       start_time: "14:00:21", 
       end_time: "24:00:11",
       headway_secs: "1000",
       exact_times: "0"
      }
    end
    
    test "valid frequency" do
      f = FrequencyTest.fill_valid_frequency
      assert f.valid?, f.errors.to_a
    end
   
    test "trip_id required" do
      f = FrequencyTest.fill_valid_frequency
      f.trip = nil
      assert f.invalid?
    end
   
    test "start_time required" do
      f = FrequencyTest.fill_valid_frequency
      f.start_time = nil
      assert f.invalid?
    end
   
    test "end_time required" do
     f = FrequencyTest.fill_valid_frequency
     f.end_time = nil
     assert f.invalid?
    end
   
    test "headway_secs required" do
     f = FrequencyTest.fill_valid_frequency
     f.headway_secs = nil
     assert f.invalid?
    end

    test "headway_secs range" do
     f = FrequencyTest.fill_valid_frequency
     f.headway_secs = -1
     assert f.invalid?
     
     f.headway_secs = 1
     f.errors.clear
     assert f.valid?, f.errors.to_a
     f.headway_secs = 1.1 #has to be integer
     assert f.invalid?
    end
    
    test "exact_times can be nil" do
      f = FrequencyTest.fill_valid_frequency
      f.exact_times = nil # has to be integer
      assert f.valid?
    end
    
    test "exact_times range" do
      
      f = FrequencyTest.fill_valid_frequency
      f.exact_times = 0.5 # has to be integer
      assert f.invalid?
      
      f.errors.clear
      f.exact_times = Frequency::NOT_EXACT   
      assert f.valid?, f.errors.to_a
    
      f.exact_times = -1 
      assert f.invalid?
       
      f.errors.clear      
      f.exact_times = Frequency::EXACT
      assert f.valid?, f.errors.to_a
      
      f.exact_times = 2
      assert f.invalid? 
      
    end
    
    test "virtual attribute trip_io_id sets and gets trip" do
      t = TripTest.fill_valid_trip
      assert t.valid?
      t.save!
      f = FrequencyTest.fill_valid_frequency
      f.trip = nil
      assert_equal f.trip, nil 
      assert_equal f.trip_io_id, nil 
      f.trip_io_id = t.io_id 
      assert_equal f.trip.io_id, t.io_id
      assert_equal f.trip_io_id, t.io_id
      assert t.valid?
    end
    
    test "not valid when virtual attribute trio_io_id not found" do
       f = FrequencyTest.fill_valid_frequency
       f.trip_io_id = "this_trip_does_not_exist"
       assert f.invalid?
    end
    
   # GTFS 
   
   test "frequency row can be imported into a Frequency model" do
      model_class = Frequency
      test_class = FrequencyTest
      exceptions = [] #exceptions, in test
      #--- common part
      feed_row = test_class.send('valid_gtfs_feed_' + model_class.to_s.split("::").last.underscore)
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
      model = test_class.send('fill_valid_' + model_class.to_s.split("::").last.underscore)
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
