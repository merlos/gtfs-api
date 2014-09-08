require 'test_helper'

module GtfsApi
  class StopTimeTest < ActiveSupport::TestCase
    
    def self.fill_valid_stop_time
      
      ## create a route
      unique = Time.now.to_f.to_s
      s = StopTest.fill_valid_stop
      s.io_id = unique
      s.save!
      ## create a trip
      t = TripTest.fill_valid_trip
      t.io_id = unique
      t.save!
      StopTime.new(
        trip: t,
        stop: s,
        arrival_time: '10:11:12',
        departure_time: '25:33:44',
        stop_sequence: '1',
        stop_headsign: 'hola',
        pickup_type: StopTime::PHONE_AGENCY,
        drop_off_type: StopTime::REGULAR, 
        dist_traveled: '100.1' )
    end
    
    def self.valid_gtfs_feed_stop_time
      unique = Time.now.to_f.to_s
      s = StopTest.fill_valid_stop
      s.io_id = unique
      s.save!
      ## create a trip
      t = TripTest.fill_valid_trip
      t.io_id = unique
      t.save!
      { 
        trip_id: t.io_id,
        stop_id: s.io_id,
        arrival_time: '10:11:12',
        departure_time: '25:33:44',
        stop_sequence: 1,
        stop_headsign: 'headsign',
        pickup_type: StopTime::PHONE_AGENCY,
        drop_off_type: StopTime::REGULAR, 
        shape_dist_traveled: 100.1 
      }
    end
    
    test 'valid stop time' do
      s = StopTimeTest.fill_valid_stop_time
      assert s.valid?
    end
    
    test 'trip_id is required' do
      s = StopTimeTest.fill_valid_stop_time
      s.trip = nil
      assert s.invalid?
    end
    
    test 'stop_id is required' do
      s = StopTimeTest.fill_valid_stop_time
      s.stop = nil
      assert s.invalid?
    end
    
    test 'is valid with arrival_time and departure time both nil' do
      s = StopTimeTest.fill_valid_stop_time
      s.arrival_time = nil
      s.departure_time = nil
      assert s.valid?
    end
    
    test 'arrival_time is optional only if departure_time not set' do
      s = StopTimeTest.fill_valid_stop_time
      s.arrival_time = nil
      assert s.invalid?
      assert (s.errors.added? :arrival_time, :set_both_times)
    end
    
    test 'departure_time is optional only if arrival_time not set' do
      s = StopTimeTest.fill_valid_stop_time
      s.departure_time = nil
      assert s.invalid?
      assert (s.errors.added? :departure_time, :set_both_times)
    end
    
    test 'is valid if departure_time and arrival_time are equal' do
      s = StopTimeTest.fill_valid_stop_time
      s.arrival_time = '10:20:30'
      s.departure_time = '10:20:30'
      assert s.valid?
    end
    
    test 'departure time must be after to arrival time' do
      s = StopTimeTest.fill_valid_stop_time
      s.arrival_time = '10:20:30'
      s.departure_time = '9:20:30'
      assert s.invalid?
      assert (s.errors.added? :departure_time, :must_be_after_arrival_time)
    end
    
    
    test 'valid gtfs spec arrival_time format is accepted' do
      # gtfs arrival time
      s = StopTimeTest.fill_valid_stop_time
      s.arrival_time = "9:44:45" #without 0
      assert s.valid?, s.errors.to_a.to_s
      s.arrival_time = "09:55:33" #with 0
      assert s.valid?, s.errors.to_a.to_s
      assert_equal Time.new(0,1,1,9,55,33,'+00:00'), s.arrival_time
      s.arrival_time = "00:00:01" #extreme 
      assert s.valid?, s.errors.to_a.to_s
      assert_equal Time.new(0000,01,01,00,00,01,'+00:00'), s.arrival_time # 0000-01-01 00:00:01
      #assign a Time directly
      s.arrival_time = Time.new(000,01,01,00,00,01,'+00:00')
      assert s.valid?
      assert Time.new(000,01,01,00,00,01,'+00:00'), s.arrival_time
    end
    
    test 'arrival_time and departure times with values greater than 24h is properly stored' do
      s = StopTimeTest.fill_valid_stop_time
      s.arrival_time = "29:55:55"
      s.departure_time = "29:55:55" # 1d + 5h 55m 55s
      assert s.valid?, s.errors.to_a.to_s
      assert_equal Time.new(0000,01,02,5,55,55,'+00:00'), s.arrival_time # 0000-01-02 5:55:55 +0000
      assert_equal Time.new(0000,01,02,5,55,55,'+00:00'), s.departure_time # 0000-01-02 5:55:55 +0000
    end
    
    test 'invalid arrival_time' do 
      s = StopTimeTest.fill_valid_stop_time
      s.arrival_time = "00:01"
      assert (s.errors.added? :arrival_time, :invalid), "invalid error was not added"
      assert s.invalid?, "00:01 gave a valid arrival time" 
    end
    
    test 'invalid arrival_time with seconds larger than 59' do 
      s = StopTimeTest.fill_valid_stop_time
      s.arrival_time = "00:00:99"
      assert s.invalid?, 'seconds set to 99 is not invalid!'
    end
    
    test "invalid arrival time with minutes larger than 59" do
      s = StopTimeTest.fill_valid_stop_time
      s.arrival_time = "00:99:00" 
      assert s.invalid?, 'seconds minutes set to 99 is not invalid!'
    end
        
    test 'valid gtfs spec departure_time format works fine' do
      # we are skipping some tests because should be the same that with arrival_time
      s = StopTimeTest.fill_valid_stop_time
      s.arrival_time = "09:55:33" #with 0
      assert s.valid?, s.errors.to_a.to_s
      assert_equal s.arrival_time, Time.new(0,1,1,9,55,33,'+00:00')
    end
        
    test 'stop_sequence is required' do
      s = StopTimeTest.fill_valid_stop_time
      s.stop_sequence = nil
      assert s.invalid?
    end
    
    test 'stop_sequence has to be a positive integer' do
       s = StopTimeTest.fill_valid_stop_time
       s.stop_sequence = -1
       assert s.invalid?
    end
    
    test 'stop_headsign is optional' do
      s = StopTimeTest.fill_valid_stop_time
      s.stop_headsign = nil
      assert s.valid?
    end
    
    test 'pickup_type is optional' do
      s = StopTimeTest.fill_valid_stop_time
      s.pickup_type = nil
      assert s.valid?
    end
    
    test 'drop_off_type is optional' do
      s = StopTimeTest.fill_valid_stop_time
      s.drop_off_type = nil
      assert s.valid?
    end
    
    test 'pickup_type valid range' do
      s = StopTimeTest.fill_valid_stop_time
      StopTime::PickupTypes.each do |k,v|
        s.pickup_type = v
        assert s.valid?
      end
    end
    
    test 'pickup_type invalid range' do 
       s = StopTimeTest.fill_valid_stop_time
       s.pickup_type = -1
       assert s.invalid?
       s2 = StopTimeTest.fill_valid_stop_time
       s2.pickup_type = 4 
       assert s2.invalid?
    end
    
    test 'drop_off_type valid range' do 
      s = StopTimeTest.fill_valid_stop_time
      s.pickup_type = StopTime::REGULAR
      assert s.valid?
      assert_equal s.pickup_type, StopTime::PickupTypes[:regular]
      s.pickup_type = StopTime::NO
      assert s.valid?
      assert_equal s.pickup_type, StopTime::PickupTypes[:no]
      s.pickup_type = StopTime::PHONE_AGENCY
      assert s.valid?
      assert_equal s.pickup_type, StopTime::PickupTypes[:phone_agency]
      s.pickup_type = StopTime::COORDINATE_WITH_DRIVER
      assert s.valid?
      assert_equal s.pickup_type, StopTime::PickupTypes[:coordinate_with_driver]
    end
    
    test 'drop_off_type invalid range' do
      s = StopTimeTest.fill_valid_stop_time
      s.drop_off_type = -1
      assert s.invalid?
      s2 = StopTimeTest.fill_valid_stop_time
      s2.drop_off_type = 4 
      assert s2.invalid?
    end
    test 'dist_traveled is optional' do 
      s = StopTimeTest.fill_valid_stop_time
      s.dist_traveled = nil
      assert s.valid?
    end
    
    test 'dist_traveled cannot to be negative' do
      s = StopTimeTest.fill_valid_stop_time
      s.dist_traveled = -1.00
      assert s.invalid?
    end
    
    test 'virtual attribute stop_io_id works' do
      stop = StopTest.fill_valid_stop
      assert stop.valid?
      stop.save!
      
      s = StopTimeTest.fill_valid_stop_time
      assert_not_equal s.stop, stop 
      s.stop_io_id = stop.io_id
      assert_equal s.stop.io_id, stop.io_id
      assert s.valid?
      s.save!
      assert_equal s.stop.io_id, stop.io_id 
    end
    
    test 'virtual attribute trip_io_id works' do
      trip = TripTest.fill_valid_trip
      assert trip.valid?
      trip.save!
      
      s = StopTimeTest.fill_valid_stop_time
      assert_not_equal s.trip, trip 
      s.trip_io_id = trip.io_id
      assert_equal s.trip.io_id, trip.io_id
      assert s.valid?
      s.save!
      assert_equal s.trip.io_id, trip.io_id 
    end
  
    test 'a stop_time row can be imported to a stop_time model' do
       feed_row = StopTimeTest.valid_gtfs_feed_stop_time
       #puts StopTime.gtfs_cols
       #puts feed_row
       model = StopTime.new_from_gtfs(feed_row)
       assert model.valid?
       StopTime.gtfs_cols.each do |model_attr, feed_col|
         # arrival time and departure time return a Time obj =! gtfs input, so we convert them
         # we use send() Because virtual attributes need cannot be called model_instance[:attr]  
         if [:arrival_time, :departure_time].include? (model_attr)
           assert_equal feed_row[feed_col], model.send(model_attr).to_gtfs, "Testing " + model_attr.to_s + " vs " + feed_col.to_s
           next
         end
         assert_equal model.send(model_attr), feed_row[feed_col], "Testing " + model_attr.to_s + " vs " + feed_col.to_s
       end
    end
    
    test "a stop_time model can be exported to gtfs row" do
      model = StopTimeTest.fill_valid_stop_time
      feed_row = model.to_gtfs
      StopTime.gtfs_cols.each do |model_attr, feed_col|
        if [:arrival_time, :departure_time].include? (model_attr)
          assert_equal feed_row[feed_col], model.send(model_attr).to_gtfs, "Testing " + model_attr.to_s + " vs " + feed_col.to_s
          next
        end
        assert_equal model.send(model_attr), feed_row[feed_col], "Testing " + model_attr.to_s + " vs " + feed_col.to_s
      end
    end
    
  end
end
