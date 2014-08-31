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
    
    def self.valid_gtfs_feed_route
      a = AgencyTest.fill_valid_agency
      a.save!
      {
        route_id: Time.new.to_f.to_s,
        agency_id: a.io_id,
        route_short_name: 'short name',
        route_long_name: 'long name',
        route_desc: 'route desc',
        route_type: Route::FUNICULAR_TYPE,
        route_url: 'http://github.com/merlos/route/url',
        route_color: 'CACADE',
        route_text_color: 'BACACA'
      }
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
    
    #
    # GTFSABLE
    #
    # IMPORT EXPORT
    
    test "routes row can be imported into a Route model" do
      model_class = Route
      test_class = RouteTest
      exceptions = [] #exceptions to avoid test
      #--- common part
      feed_row = test_class.send('valid_gtfs_feed_' + model_class.to_s.split("::").last.underscore)
      model = model_class.new_from_gtfs(feed_row)
      assert model.valid?
      model_class.gtfs_cols.each do |model_attr, feed_col|
        next if exceptions.include? (model_attr)
        assert_equal model.send(model_attr), feed_row[feed_col], "Testing " + model_attr.to_s + " vs " + feed_col.to_s
      end
      #------
    end
    
    test "a Route model can be exported into a gtfs row" do
      model_class = Route
      test_class = RouteTest
      exceptions = []
      #------ Common_part
      model = test_class.send('fill_valid_' + model_class.to_s.split("::").last.underscore)
      feed_row = model.to_gtfs
      model_class.gtfs_cols.each do |model_attr, feed_col|
        next if exceptions.include? (model_attr)
        assert_equal model.send(model_attr), feed_row[feed_col], "Testing " + model_attr.to_s + " vs " + feed_col.to_s
      end
    end
      
    
  
  end #class
end #module
