require 'test_helper'

module GtfsApi
  
  class RouteTest < ActiveSupport::TestCase
  
    # it's ok For testing VALIDATORS 
    def self.fill_valid_route
      Route.new( 
        io_id: 'route_' + Time.new.to_f.to_s,
        short_name:'short name',
        long_name: 'route_long_name',
        desc: "route description",
        route_type: Route::FUNICULAR_TYPE,
        url: 'http://github.com/merlos',
        color: 'FFCCDD',
        text_color: '000000'
      )
    end
    
    def self.valid_gtfs_feed_route
      a = AgencyTest.fill_valid_agency
      a.save!
      {
        route_id: 'route_' + Time.new.to_f.to_s,
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
    
    test "is valid when route short name is present but not route long" do
      r = RouteTest.fill_valid_route
      r.short_name = nil
      assert r.valid?
    end
    
    test "is valid when route long name is present but not route short name" do
      r = RouteTest.fill_valid_route
      r.long_name = nil
      assert r.valid?
    end
    
    test "is invalid when neither long name nor short name are present" do
      r = RouteTest.fill_valid_route
      r.short_name = nil
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
    
    test "route_type out of upper limit is invalid" do
      r = RouteTest.fill_valid_route
      r.route_type = 1703 # valid range is [0..1703]
      assert r.invalid?
    end
    
    test "route_type has to be positive" do
      r = RouteTest.fill_valid_route
      r.route_type = -1
      assert r.invalid?
    end
  
    test "route_type has to be in RouteTypes constant" do
       r = RouteTest.fill_valid_route
       r.route_type = 1250
       assert r.invalid?
       assert (r.errors.added? :route_type, :invalid)
    end
    test "url is optional" do
      r = RouteTest.fill_valid_route
      r.url = nil
      assert r.valid?
    end
    
    test "http and https are valid url formats" do
      r = RouteTest.fill_valid_route
      r.url = "http://www.foofoofoo.es/blow"
      assert r.valid?, r.errors.to_a.to_s
      r.url = "https://barbarbar.es/drunk"
      assert r.valid?, r.errors.to_a.to_s
    end
    
    test "ftp addresses are an invalid url format" do
      r = RouteTest.fill_valid_route
      r.url = "ftp://www.fetepe.es"
      assert r.invalid?
    end
    
    test 'absolute url is invalid format' do
      r = RouteTest.fill_valid_route
      r.url = "/rururutatata/cacadevaca"
      assert r.invalid?
    end  
        
    test "color attribute is optional" do
      r = RouteTest.fill_valid_route
      r.color = nil
      assert r.valid?
    end
    
    test "color length cannot be less than 6" do
      r = RouteTest.fill_valid_route
      r.color = "12345"
      assert r.invalid?
    end
      
    test "color legth cannot be larger than 6" do
      r = RouteTest.fill_valid_route
      r.color = "1234567"
      assert r.invalid?
    end
    
    test "color has to be an hex value" do
      r = RouteTest.fill_valid_route
      r.color = "GGGGGG"
      assert r.invalid?
    end
    
    test "text_color is optional" do
      r = RouteTest.fill_valid_route
      r.color = nil
      assert r.valid?
    end
    test "text_color length cannot be less than 6" do  
      r = RouteTest.fill_valid_route
      r.color = "12345" 
      assert r.invalid?
    end
    
    test "text_color length cannot be greater than 6" do
      r = RouteTest.fill_valid_route
      r.color="1234567"
      assert r.invalid?
    end
    
    test "text_color character have to be in hex string" do  
      r = RouteTest.fill_valid_route
      r.color="GGGGGG"
      assert r.invalid?
    end
        
    # database stuff
    test "uniqueness of route" do
      r = RouteTest.fill_valid_route
      r.io_id = "route_66"
      r.save!
      r2 = RouteTest.fill_valid_route
      r2.io_id = "route_66"
      assert r2.invalid?
      assert_raises ( ActiveRecord::RecordInvalid) {r2.save!}
    end
    
    # check belongs_to agency
    test 'belongs to agency' do
      a = AgencyTest.fill_valid_agency
      a.io_id = "known_agency_id"
      r = RouteTest.fill_valid_route
      r.agency = a
      assert r.valid?
      r.save!
      # retrieve the saved route and check if agency is linked
      r2 = Route.find_by io_id: r.io_id
      assert_equal a.io_id, r2.agency.io_id

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
