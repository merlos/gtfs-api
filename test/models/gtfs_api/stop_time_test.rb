# The MIT License (MIT)
#
# Copyright (c) 2016 Juan M. Merlos, panatrans.org
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.



require 'test_helper'

module GtfsApi
  class StopTimeTest < ActiveSupport::TestCase

    def self.fill_valid_model

      ## create a route
      unique = Time.now.to_f.to_s
      s = StopTest.fill_valid_model
      s.io_id = unique
      s.save!
      ## create a trip
      t = TripTest.fill_valid_model
      t.io_id = unique
      t.save!
      feed = FeedTest.fill_valid_model
      feed.save!

      StopTime.new(
        trip: t,
        stop: s,
        arrival_time: '10:11:12',
        departure_time: '25:33:44',
        stop_sequence: '1',
        stop_headsign: 'hola',
        pickup_type: StopTime::PHONE_AGENCY,
        drop_off_type: StopTime::REGULAR,
        dist_traveled: '100.1',
        feed: feed )
    end

    def self.valid_gtfs_feed_row
      unique = Time.now.to_f.to_s
      s = StopTest.fill_valid_model
      s.io_id = unique
      s.save!
      ## create a trip
      t = TripTest.fill_valid_model
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

    def setup
      @model = StopTimeTest.fill_valid_model
    end

    test 'valid stop time' do
      assert @model.valid?
    end

    test 'trip_id is required' do
      @model.trip = nil
      assert @model.invalid?
    end

    test 'stop_id is required' do
      @model.stop = nil
      assert @model.invalid?
    end

    test 'is valid with arrival_time and departure time both nil' do
      @model.arrival_time = nil
      @model.departure_time = nil
      assert @model.valid?
    end

    test 'arrival_time is optional only if departure_time not set' do
      @model.arrival_time = nil
      assert @model.invalid?
      assert (@model.errors.added? :arrival_time, :set_both_times)
    end

    test 'departure_time is optional only if arrival_time not set' do
      @model.departure_time = nil
      assert @model.invalid?
      assert (@model.errors.added? :departure_time, :set_both_times)
    end

    test 'is valid if departure_time and arrival_time are equal' do
      @model.arrival_time = '10:20:30'
      @model.departure_time = '10:20:30'
      assert @model.valid?
    end

    test 'departure time must be after to arrival time' do
      @model.arrival_time = '10:20:30'
      @model.departure_time = '9:20:30'
      assert @model.invalid?
      assert (@model.errors.added? :departure_time, :must_be_after_arrival_time)
    end


    test 'valid gtfs spec arrival_time format is accepted' do
      # gtfs arrival time
      @model.arrival_time = "9:44:45" #without 0
      assert @model.valid?, @model.errors.to_a.to_s
      @model.arrival_time = "09:55:33" #with 0
      assert @model.valid?, @model.errors.to_a.to_s
      assert_equal Time.new(0,1,1,9,55,33,'+00:00'), @model.arrival_time
      @model.arrival_time = "00:00:01" #extreme
      assert @model.valid?, @model.errors.to_a.to_s
      assert_equal Time.new(0000,01,01,00,00,01,'+00:00'), @model.arrival_time # 0000-01-01 00:00:01
      #assign a Time directly
      @model.arrival_time = Time.new(000,01,01,00,00,01,'+00:00')
      assert @model.valid?
      assert Time.new(000,01,01,00,00,01,'+00:00'), @model.arrival_time
    end

    test 'arrival_time and departure times with values greater than 24h is properly stored' do
      @model.arrival_time = "29:55:55"
      @model.departure_time = "29:55:55" # 1d + 5h 55m 55s
      assert @model.valid?, @model.errors.to_a.to_s
      assert_equal Time.new(0000,01,02,5,55,55,'+00:00'), @model.arrival_time # 0000-01-02 5:55:55 +0000
      assert_equal Time.new(0000,01,02,5,55,55,'+00:00'), @model.departure_time # 0000-01-02 5:55:55 +0000
    end

    test 'invalid arrival_time' do
      @model.arrival_time = "00:01"
      assert (@model.errors.added? :arrival_time, :invalid), "invalid error was not added"
      assert @model.invalid?, "00:01 gave a valid arrival time"
    end

    test 'invalid arrival_time with seconds larger than 59' do
      @model.arrival_time = "00:00:99"
      assert @model.invalid?, 'seconds set to 99 is not invalid!'
    end

    test "invalid arrival time with minutes larger than 59" do
      @model.arrival_time = "00:99:00"
      assert @model.invalid?, 'seconds minutes set to 99 is not invalid!'
    end

    test 'valid gtfs spec departure_time format works fine' do
      # we are skipping some tests because should be the same that with arrival_time
      @model.arrival_time = "09:55:33" #with 0
      assert @model.valid?, @model.errors.to_a.to_s
      assert_equal @model.arrival_time, Time.new(0,1,1,9,55,33,'+00:00')
    end

    test 'stop_sequence is required' do
      @model.stop_sequence = nil
      assert @model.invalid?
    end

    test 'stop_sequence has to be a positive integer' do
       @model.stop_sequence = -1
       assert @model.invalid?
    end

    test 'stop_headsign is optional' do
      @model.stop_headsign = nil
      assert @model.valid?
    end

    test 'pickup_type is optional' do
      @model.pickup_type = nil
      assert @model.valid?
    end

    test 'drop_off_type is optional' do
      @model.drop_off_type = nil
      assert @model.valid?
    end

    test 'pickup_type valid range' do
      StopTime::PickupTypes.each do |k,v|
        @model.pickup_type = v
        assert @model.valid?
      end
    end

    test 'pickup_type invalid range' do
       @model.pickup_type = -1
       assert @model.invalid?
       s2 = StopTimeTest.fill_valid_model
       s2.pickup_type = 4
       assert s2.invalid?
    end

    test 'drop_off_type valid range' do
      @model.pickup_type = StopTime::REGULAR
      assert @model.valid?
      assert_equal @model.pickup_type, StopTime::PickupTypes[:regular]
      @model.pickup_type = StopTime::NO
      assert @model.valid?
      assert_equal @model.pickup_type, StopTime::PickupTypes[:no]
      @model.pickup_type = StopTime::PHONE_AGENCY
      assert @model.valid?
      assert_equal @model.pickup_type, StopTime::PickupTypes[:phone_agency]
      @model.pickup_type = StopTime::COORDINATE_WITH_DRIVER
      assert @model.valid?
      assert_equal @model.pickup_type, StopTime::PickupTypes[:coordinate_with_driver]
    end

    test 'drop_off_type invalid range' do
      @model.drop_off_type = -1
      assert @model.invalid?
      s2 = StopTimeTest.fill_valid_model
      s2.drop_off_type = 4
      assert s2.invalid?
    end
    test 'dist_traveled is optional' do
      @model.dist_traveled = nil
      assert @model.valid?
    end

    test 'dist_traveled cannot to be negative' do
      @model.dist_traveled = -1.00
      assert @model.invalid?
    end

    test 'virtual attribute stop_io_id works' do
      stop = StopTest.fill_valid_model
      assert stop.valid?
      stop.save!

      assert_not_equal @model.stop, stop
      @model.stop_io_id = stop.io_id
      assert_equal @model.stop.io_id, stop.io_id
      assert @model.valid?
      @model.save!
      assert_equal @model.stop.io_id, stop.io_id
    end

    test 'virtual attribute trip_io_id works' do
      trip = TripTest.fill_valid_model
      assert trip.valid?
      trip.save!

      assert_not_equal @model.trip, trip
      @model.trip_io_id = trip.io_id
      assert_equal @model.trip.io_id, trip.io_id
      assert @model.valid?
      @model.save!
      assert_equal @model.trip.io_id, trip.io_id
    end

    #
    # GTFSABLE IMPORT/EXPORT
    #

    test 'a stop_time row can be imported to a stop_time model' do
       feed_row = StopTimeTest.valid_gtfs_feed_row
       #puts StopTime.gtfs_cols
       #puts feed_row
       feed = FeedTest.fill_valid_model
       feed.save!
       model = StopTime.new_from_gtfs(feed_row,feed)
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
      model = StopTimeTest.fill_valid_model
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
