require 'test_helper'

module GtfsApi
  class FrequencyTest < ActiveSupport::TestCase
    
    def fill_valid_frequency
      trip = Trip.find_by_io_id('_trip_one') 
      return Frequency.new(
      trip: trip,
      start_time: "14:00:21", 
      end_time: "15:00:22",
      headway_secs: 1000,
      exact_times: 0)
    end
    
    test "valid frequency" do
      f = self.fill_valid_frequency
      assert f.valid?, f.errors.to_a
    end
   
    test "trip_id required" do
      f = self.fill_valid_frequency
      f.trip = nil
      assert f.invalid?
    end
   
    test "start_time required" do
      f = self.fill_valid_frequency
      f.start_time = nil
      assert f.invalid?
    end
   
    test "end_time required" do
     f = self.fill_valid_frequency
     f.end_time = nil
     assert f.invalid?
    end
   
    test "headway_secs required" do
     f = self.fill_valid_frequency
     f.headway_secs = nil
     assert f.invalid?
    end

    test "headway_secs range" do
     f = self.fill_valid_frequency
     f.headway_secs = -1
     assert f.invalid?
     
     f.headway_secs = 1
     f.errors.clear
     assert f.valid?, f.errors.to_a
     f.headway_secs = 1.1 #has to be integer
     assert f.invalid?
    end
    
    test "exact_times range" do
      
      f = self.fill_valid_frequency
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
      f = self.fill_valid_frequency
      f.trip = nil
      assert_equal f.trip, nil 
      assert_equal f.trip_io_id, nil 
      f.trip_io_id = t.io_id 
      assert_equal f.trip.io_id, t.io_id
      assert_equal f.trip_io_id, t.io_id
      assert t.valid?
    end
    
  end
end
