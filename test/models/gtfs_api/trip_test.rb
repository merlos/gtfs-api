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
  class TripTest < ActiveSupport::TestCase

    #Creates a trip with
    # 1 valid shape with two points
    # 2 calendars
    # 1 calendar_date
    def self.fill_valid_model
      agency = GtfsApi::AgencyTest.fill_valid_model
      agency.save!

      feed = FeedTest.fill_valid_model
      feed.save!

      route = RouteTest.fill_valid_model
      route.save!

      shape1 = ShapeTest.fill_valid_model
      shape1.save!
      shape2 = ShapeTest.fill_valid_model
      shape2.io_id = shape1.io_id #two points with the same id
      shape2.save!

      service = ServiceTest.fill_valid_model
      service.save!

      cal = CalendarTest.fill_valid_model
      cal.service = service
      cal.save!

      cal_date = CalendarDateTest.fill_valid_model
      cal_date.service = service
      cal_date.save!

      return Trip.new(
       io_id: 'trip' + Time.new.to_f.to_s,
       route: route,
       service: service,
       headsign: 'headsign',
       short_name: 'short_name',
       direction: 1,
       block_id: 'block_id',
       shape_id: shape1.io_id,
       wheelchair_accesible: Trip::YES,
       feed: feed);
    end

    def self.valid_gtfs_feed_row
      t = TripTest.fill_valid_model
      {
        trip_id: t.io_id,
        route_id: t.route.io_id,
        service_id: t.service.io_id,
        trip_headsign: 'trip headsign',
        trip_short_name: 'trip short name',
        direction: '0',
        block_id: 'block_id',
        shape_id: t.shape_id,
        wheelchair_accesible: '0',
        bikes_allowed: '0',
      }
    end

    def setup
      @model = TripTest.fill_valid_model
    end

    test 'valid trip' do
      assert @model.valid?
    end

    test 'trip io_id uniqueness' do
      @model.io_id = 'pepe'
      assert @model.valid?
      @model.save!
      t2 = TripTest.fill_valid_model
      t2.io_id = 'pepe'
      assert t2.invalid?
      assert_raises ( ActiveRecord::RecordInvalid) {t2.save!}
    end

    test 'route presence is required' do
      @model.route = nil
      assert @model.invalid?
    end

    test 'service presence is required' do
      @model.service = nil
      assert @model.invalid?
    end

    test 'direction is optional' do
      @model.direction = nil
      assert @model.valid?
    end

    test 'direction valid range' do
      @model.direction = Trip::Direction[:outbound_travel]
      assert @model.valid?, @model.errors.to_a.to_s
      @model.direction = Trip::INBOUND_TRAVEL
      assert @model.valid?
    end

    test 'direction invalid ranges' do
      @model.direction = -1
      assert @model.invalid?
      t2 = TripTest.fill_valid_model
      t2.direction = 2
      assert @model.invalid?
    end

    test 'wheelchair_accesible is optional' do
      @model.wheelchair_accesible = nil
      assert @model.valid?
    end

    test 'wheelchair_accesible valid range' do
      @model.wheelchair_accesible = Trip::NO_INFO
      assert @model.valid?
      @model.wheelchair_accesible = Trip::YES
      assert @model.valid?
      @model.wheelchair_accesible = Trip::NO
      assert @model.valid?
    end

    test 'wheelchair_accesible invalid range' do
       @model.wheelchair_accesible = -1
       assert @model.invalid?
       t2 = TripTest.fill_valid_model
       @model.wheelchair_accesible = 3
       assert @model.invalid?
    end

    test 'bikes_allowed is optional' do
      @model.bikes_allowed = nil
      assert @model.valid?
    end

    test 'bikes_allowed valid range' do
      @model.bikes_allowed = Trip::NO_INFO
      assert @model.valid?
      @model.bikes_allowed = Trip::YES
      assert @model.valid?
      @model.bikes_allowed = Trip::NO
      assert @model.valid?
    end

    test 'bikes_allowed invalid range' do
      @model.wheelchair_accesible = -1
      assert @model.invalid?
      t2 = TripTest.fill_valid_model
      @model.wheelchair_accesible = 3
      assert @model.invalid?
    end


    test 'that validates shape_id exists if set' do
      @model.shape_id = "lalalala" #a shape_id that does not exist
      assert @model.invalid?
    end

    #TEST ASSOCIAIONS

    test 'shapes association returns shapes' do
      sh1 = Shape.where(io_id: @model.shape_id)
      #puts "sh1:" + sh1.count.to_s
      #puts "shapes: " + t.shapes.length.to_s
      assert_equal @model.shapes.size, sh1.count
      @model.shapes.each do |shape|
        assert_equal sh1.first.io_id, shape.io_id
        #puts shape.io_id
      end
    end

    test 'calendar association returns calendars' do
      cal1 = Calendar.where(service_id: @model.service_id)
      assert_equal @model.calendars.size, cal1.count
      @model.calendars.each do |cal|
        assert_equal @model.service_id, cal.service_id
      end
    end

    test 'calendar_dates association is correctly defined' do
      cal1 = CalendarDate.where(service_id: @model.service_id)
      assert_equal @model.calendar_dates.size, cal1.count
      @model.calendar_dates.each do |cal|
        assert_equal @model.service_id, cal.service_id
      end
    end


    # VIRTUAL ATTRIBUTES

    test 'that validates route has to exist' do
      @model.route_io_id = "fake route"
      assert @model.invalid?
    end

    test 'that validates service exists' do
      @model.service_io_id = "lololololo" #a service that does not exist
      assert @model.invalid?
    end

    test 'virtual attribute route_io_id sets the route object' do
      r = RouteTest.fill_valid_model
      assert r.valid?
      r.save!
      @model.route = nil
      assert_equal @model.route, nil #if the trip has no route set
      assert_equal @model.route_io_id, nil # trip.route_io_id is therefore nil
      @model.route_io_id = r.io_id # by assigning the route_io_id we assign the route as well
      assert_equal r.io_id, @model.route.io_id #check it out
      assert @model.valid?
      @model.save!
      assert_equal r.io_id, @model.route.io_id #check now I can access route
    end

    test 'virtual attribute service_io_id sets the service object' do
      service = ServiceTest.fill_valid_model
      service.save!
      @model.service_io_id = service.io_id
      assert_equal service.io_id, @model.service.io_id
    end

    #
    # GTFSABLE IMPORT/EXPORT
    #

    test 'trip row can be imported into a Trip model' do
       model_class = Trip
       test_class = TripTest
       exceptions = [] #exceptions, in test
       #--- common part
       feed_row = test_class.valid_gtfs_feed_row
       #puts feed_row
       feed = FeedTest.fill_valid_model
       feed.save!
       model = model_class.new_from_gtfs(feed_row, feed)
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



     test 'a Trip model can be exported into a gtfs row' do
       model_class = Trip
       test_class = TripTest
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
