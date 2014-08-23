require 'test_helper'

module GtfsApi
  
  class RouteTest < ActiveSupport::TestCase
  
    # it's ok For testing VALIDATORS 
    def self.fill_valid_route
      r = Route.new 
      r.io_id = 'RouteId'
      r.short_name = 'short name'
      r.long_name = 'route_long_name'
      r.desc = "route description"
      r.route_type = Route::FUNICULAR_TYPE
      r.url = 'http://github.com/merlos'
      r.color = 'FFCCDD'
      r.text_color = '000000'
      return r
    end
  
    test "route io_id has to be present" do
      r = RouteTest.fill_valid_route
      r.io_id = nil
      assert r.invalid?
    end
    
    test "route short name present" do
      r = RouteTest.fill_valid_route
      r.short_name = nil
      assert r.invalid?
    end
    
    test "route long name present" do
      r = RouteTest.fill_valid_route
      r.long_name = nil
      assert r.invalid?
    end
    
    test "route_types are defined and valid" do
      r = RouteTest.fill_valid_route
      r.route_type = Route::TRAM_TYPE
      assert r.valid?
      r.route_type = Route::SUBWAY_TYPE
      assert r.valid?
      r.route_type = Route::RAIL_TYPE
      assert r.valid?
      r.route_type = Route::BUS_TYPE
      assert r.valid?
      r.route_type = Route::FERRY_TYPE
      assert r.valid?
      r.route_type = Route::CABLE_CAR_TYPE
      assert r.valid?
      r.route_type = Route::GONDOLA_TYPE
      assert r.valid?
      r.route_type = Route::FUNICULAR_TYPE
      assert r.valid?
    end
    
    test "route type out of range" do
      r = RouteTest.fill_valid_route
      r.route_type = 8 # valid range is [0..7]
      assert r.invalid?
      r2 = RouteTest.fill_valid_route
      assert r2.valid?
      r2.route_type = -1
      assert r2.invalid?
    end
  
    test "url is optional" do
      r = RouteTest.fill_valid_route
      r.url = nil
      assert r.valid?
    end
    
    test "some url invalid formats" do
      r = RouteTest.fill_valid_route
      r.url = "http://www.foofoofoo.es/blow"
      assert r.valid?, r.errors.to_a.to_s
      r.url = "https://barbarbar.es/drunk"
      assert r.valid?, r.errors.to_a.to_s
      r.url = "ftp://www.fetepe.es"
      assert r.invalid?
      r2 = RouteTest.fill_valid_route
      r2.url = "/rururutatata/cacadevaca"
      assert r2.invalid?
    end  
        
    test "route color can be nil and length" do
      r = RouteTest.fill_valid_route
      r.color = nil
      assert r.valid?
      r.color = "1234567" # valid range is [0..F]
      assert r.invalid?
    end
    
    test "route text color nil and length" do
      r = RouteTest.fill_valid_route
      r.color = nil
      assert r.valid?
      
      r.color = "1234" # valid range is [0..F]
      assert r.invalid?
      
      r.errors.clear
      r.color="ZZZZZZ"
      assert r.invalid?
      
      r.errors.clear
      r.color="123456"
      assert r.valid?
    
    end
      
    # database stuff
    test "uniqueness of route" do
      r = RouteTest.fill_valid_route
      r.save!
      r2 = RouteTest.fill_valid_route
      assert_raises ( ActiveRecord::RecordInvalid) {r2.save!}
      r3 = RouteTest.fill_valid_route
      r3.io_id="newValidPid"
      assert_nothing_raised(ActiveRecord::RecordInvalid) {r3.save!}
    end
    
    # check belongs_to agency
    # uses fixtures
    test 'belongs to agency' do
      
      r = Route.find_by io_id:'_route_one'
      assert_equal('_agency_one', r.agency.io_id )
      
      # _agency_one should have been linked to 2 routes
      a= Agency.find_by_io_id('_agency_one')
      assert_equal(2, a.routes.count)
    end
    
    test 'virtual attribute agency_io_id works properly' do
      a = AgencyTest.fill_valid_agency
      assert a.valid?
      a.save!
      r = RouteTest.fill_valid_route
      assert_equal r.agency, nil #the route has no agency set
      assert_equal r.agency_io_id, nil # agency_io_id is therefore nil
      r.agency_io_id = a.io_id # by assigning the io_id we assign the agency as well
      assert_equal r.agency.io_id, a.io_id
      assert r.valid?
      r.save!
      assert_equal r.agency.io_id, a.io_id #check no I can access agency
    end
  
  end #class
end #module
