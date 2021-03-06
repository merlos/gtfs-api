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
  class StopTest < ActiveSupport::TestCase
    # fill a Stop object with valid data
    # no zone and parent_stop is filled
    def self.fill_valid_model(feed = nil)
      if feed.nil? then
        feed = FeedTest.fill_valid_model
        feed.save!
      end
      feed_prefix = feed.prefix.present? ? feed.prefix : ''
      Stop.new(
      io_id: feed_prefix + '_stop_' + Time.now.to_f.to_s,
      code: 'stop_code',
      name: 'stop_name',
      desc: 'stop_desc',
      lat: 1.1,
      lon: 2.2,
      url: 'http://github.com/merlos/',
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
        stop_id:  Time.now.to_f.to_s,
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


    def self.valid_gtfs_feed_row_for_feed(feed)
      parent_station = self.fill_valid_model feed
      parent_station.location_type = GtfsApi::Stop::LocationTypes[:station]
      parent_station.save!
      #puts parent_station.inspect
      row = self.valid_gtfs_feed_row
      # src rows do not have the feed prefix
      row[:stop_id] = feed.prefix.present? ? row[:stop_id].gsub(feed.prefix,'') : row[:stop_id]
      row[:parent_station] = feed.prefix.present? ? parent_station.io_id.gsub(feed.prefix,'') : parent.station.io_id
      #puts row
      return row
    end

    def setup
      @model = StopTest.fill_valid_model
    end

    test "valid stop is valid" do
      assert @model.valid?
    end

    test "stop io_id presence is mandatory" do
      @model.io_id = nil
      assert @model.invalid?
    end

    test "stop name presence" do
      @model.name = nil
      assert @model.invalid?
    end

    test "stop lat presence is required" do
      @model.lat = nil
      assert @model.invalid?
    end

    test "stop lon presence is required" do
      @model.lon = nil
      assert @model.invalid?
    end

    test "lat range is between 90 and -90" do
      @model.lat = 89.99
      assert @model.valid?
      @model.lat = -89.99
      assert @model.valid?
      @model.lat = 90.1
      assert @model.invalid?
      s2 = StopTest.fill_valid_model
      s2.lat = -90.1
      assert s2.invalid?
    end

    test "lon range is between 180 y -180" do
      @model.lon = 179.99
      assert @model.valid?
      @model.lon = -179.99
      assert @model.valid?
      @model.lon = 180.1
      assert @model.invalid?
      s2 = StopTest.fill_valid_model
      s2.lon = -180.1
      assert s2.invalid?
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
    test 'parent_station association works' do
      # create the parent station stop
      parent_station = StopTest.fill_valid_model
      parent_station.location_type = GtfsApi::Stop::LocationTypes[:station]
      parent_station.save!
      # asssignt the stop
      @model.parent_station = parent_station
      @model.save!
      # check that the relation was saved
      stop = GtfsApi::Stop.find(@model.id)
      assert_equal stop.parent_station.id, parent_station.id
    end
    #
    # GTFSABLE IMPORT/EXPORT
    #

    test "stop file row can be imported into a Stop model" do
       model_class = Stop
       test_class = StopTest
       exceptions = [] #exceptions, in test
       #--- common part
       feed_row = test_class.valid_gtfs_feed_row
       #puts feed_row
       feed = FeedTest.fill_valid_model
       feed.save!
       model = model_class.new_from_gtfs(feed_row, feed)
       assert model.valid?
       model_class.gtfs_cols.each do |model_attr, feed_col|
         next if exceptions.include? (model_attr)
         model_value = model.send(model_attr)
         model_value = model_value.to_s if model_value.is_a? Numeric
         assert_equal feed_row[feed_col], model_value, "Testing " + model_attr.to_s + " vs " + feed_col.to_s
       end
       #------
     end

     test "stop file row can be imported when feed has a prefix" do
       model_class = Stop
       test_class = StopTest
       exceptions = [] #exceptions, in test
       generic_row_import_test_for_feed_with_prefix(model_class, test_class)
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
       parent_station = GtfsApi::StopTest.fill_valid_model
       parent_station.location_type = GtfsApi::Stop::LocationTypes[:station]
       parent_station.save!
       feed_row = GtfsApi::StopTest.valid_gtfs_feed_row
       feed_row[:parent_station] = parent_station.io_id
       #puts feed_row
       feed = FeedTest.fill_valid_model
       feed.save!
       model = Stop.new_from_gtfs(feed_row, feed)
       #puts model.inspect
       assert model.valid?, model.errors.to_a.to_s
       assert_equal parent_station.id, model.parent_station.id
     end


     test "a Stop model that belongs to a station can be exported" do

     end
  end # class
end # module
