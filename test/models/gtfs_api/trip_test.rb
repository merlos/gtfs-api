require 'test_helper'



module GtfsApi
  class TripTest < ActiveSupport::TestCase

    #Creates a trip with
    # 1 valid shape with two points
    # 2 calendars
    # 1 calendar_date
    def self.fill_valid_trip
      a = GtfsApi::AgencyTest.fill_valid_agency
      a.save! if a.valid? # save only if it does not exist
      uniquer = Time.now.to_f.to_s
      r = Route.new(
          io_id: 'rt_1' + uniquer,
          agency: a,
          short_name: "a",
          long_name: 'a route',
          route_type: 0
          )
      #assert r.valid?
      r.save!
      
      s= Shape.new(
        io_id: 'sh_1' + uniquer,
        pt_lat: 2.1,
        pt_lon: 3.1,
        pt_sequence: 1,
        dist_traveled: 0
      )
      #assert s.valid?
      s.save!
      
      s2 = Shape.new(
        io_id: 'sh_1' + uniquer,
        pt_lat: 2.1,
        pt_lon: 3.1,
        pt_sequence: 2,
        dist_traveled: 100
       )
      #assert s2.valid?
      s2.save!
      c = Calendar.new(
        io_id: 'cal_1' + uniquer,
        monday: Calendar::AVAILABLE,
        tuesday: Calendar::AVAILABLE,
        wednesday: Calendar::AVAILABLE,
        thursday: Calendar::AVAILABLE,
        friday: Calendar::AVAILABLE,
        saturday: Calendar::AVAILABLE,
        sunday: Calendar::AVAILABLE,
        start_date: '2014-01-20',
        end_date: '2014-03-15'
      )
      #assert c.valid?
      c.save!
      c2 = Calendar.new(
        io_id: 'cal_2' + uniquer,
        monday: 0,
        tuesday: 0,
        wednesday: 0,
        thursday: 0,
        friday: 0,
        saturday: Calendar::AVAILABLE,
        sunday: Calendar::AVAILABLE,
        start_date: '2015-01-20',
        end_date: '2015-03-15'
      )
      #assert c2.valid?
      c2.save!
      return Trip.new(
       io_id: 'trip' + uniquer,
       route: r,
       service_id: c.io_id,
       headsign: 'headsign',
       short_name: 'short_name',
       direction_id: 1,
       block_id: 'block_id',
       shape_id: s.io_id,
       wheelchair_accesible: Trip::YES);
    end
    #
    #VALIDATION TESTS
    #
    
    test 'valid trip' do
      t = TripTest.fill_valid_trip
      assert t.valid?
    end
    
    test 'trip io_id uniqueness' do
      t = TripTest.fill_valid_trip
      t.io_id = 'pepe'
      assert t.valid?
      t.save!
      t2 = TripTest.fill_valid_trip
      t2.io_id = 'pepe'
      assert t2.invalid?
      assert_raises ( ActiveRecord::RecordInvalid) {t2.save!}    
    end
    
    test 'route presence is required' do
      t = TripTest.fill_valid_trip
      t.route = nil
      assert t.invalid?
    end
    
    test 'service_id presence is required' do
      t = TripTest.fill_valid_trip
      t.service_id = nil
      assert t.invalid?
    end
    
    test 'direction_id is optional' do
      t = TripTest.fill_valid_trip
      t.direction_id = nil
      assert t.valid?
    end
    
    test 'direction_id valid range' do
      t = TripTest.fill_valid_trip
      t.direction_id = Trip::Direction[:outbound_travel]
      assert t.valid?, t.errors.to_a.to_s
      t.direction_id = Trip::INBOUND_TRAVEL
      assert t.valid?
    end
    
    test 'direction_id invalid ranges' do
      t = TripTest.fill_valid_trip
      t.direction_id = -1 
      assert t.invalid?
      t2 = TripTest.fill_valid_trip
      t2.direction_id = 2
      assert t.invalid?
    end
    
    test 'wheelchair_accesible is optional' do
      t = TripTest.fill_valid_trip
      t.wheelchair_accesible = nil
      assert t.valid?
    end
    
    test 'wheelchair_accesible valid range' do
      t = TripTest.fill_valid_trip
      t.wheelchair_accesible = Trip::NO_INFO
      assert t.valid?
      t.wheelchair_accesible = Trip::YES
      assert t.valid?
      t.wheelchair_accesible = Trip::NO
      assert t.valid?
    end
    
    test 'wheelchair_accesible invalid range' do
       t = TripTest.fill_valid_trip
       t.wheelchair_accesible = -1
       assert t.invalid?
       t2 = TripTest.fill_valid_trip
       t.wheelchair_accesible = 3
       assert t.invalid?
    end
    
    test 'bikes_allowed is optional' do
      t = TripTest.fill_valid_trip
      t.bikes_allowed = nil
      assert t.valid?
    end
    
    test 'bikes_allowed valid range' do
      t = TripTest.fill_valid_trip
      t.bikes_allowed = Trip::NO_INFO
      assert t.valid?
      t.bikes_allowed = Trip::YES
      assert t.valid?
      t.bikes_allowed = Trip::NO
      assert t.valid?
    end
    
    test 'bikes_allowed invalid range' do
      t = TripTest.fill_valid_trip
      t.wheelchair_accesible = -1
      assert t.invalid?
      t2 = TripTest.fill_valid_trip
      t.wheelchair_accesible = 3
      assert t.invalid?
    end
    
    test 'that validates shape_id exists if set' do
      t = TripTest.fill_valid_trip
      t.shape_id = "lalalala" #a shape_id that does not exist
      assert t.invalid?
    end
    
    test 'that validates service_id exists if set' do
      t = TripTest.fill_valid_trip
      t.service_id = "lololololo" #a service that does not exist
      assert t.invalid?
    end
    
    
    #TEST ASSOCIAIONS
    
    test 'shapes association returns shapes' do
      t = TripTest.fill_valid_trip
      
      sh1 = Shape.where(io_id: t.shape_id)
      #puts "sh1:" + sh1.count.to_s
      #puts "shapes: " + t.shapes.length.to_s
      assert_equal t.shapes.size, sh1.count
      t.shapes.each do |shape|
        assert_equal sh1.first.io_id, shape.io_id 
        #puts shape.io_id
      end
    end
    
    test 'calendar association returns calendars' do
      t = TripTest.fill_valid_trip
      cal1 = Calendar.where(io_id: t.service_id)
      assert_equal t.calendars.size, cal1.count
      t.calendars.each do |cal|
        assert_equal t.service_id, cal.io_id
      end
    end
    
    test 'calendar_dates association is correctly defined' do
      t = TripTest.fill_valid_trip
      cal1 = CalendarDate.where(io_id: t.service_id)
      assert_equal t.calendar_dates.size, cal1.count
      t.calendar_dates.each do |cal|
        assert_equal t.service_id, cal.io_id
      end 
    end
    
    # Test Virtual Attribute
    test 'virtual attribute route_io_id works properly' do
      r = RouteTest.fill_valid_route
      assert r.valid?
      r.save!
      t = TripTest.fill_valid_trip
      t.route = nil
      assert_equal t.route, nil #the route has no agency set
      assert_equal t.route_io_id, nil # trip.route_io_id is therefore nil
      t.route_io_id = r.io_id # by assigning the route_io_id we assign the route as well      
      assert_equal t.route.io_id, r.io_id #check it out
      assert t.valid?
      t.save!
      assert_equal t.route.io_id, r.io_id #check now I can access agency
    end
    
  end
end
