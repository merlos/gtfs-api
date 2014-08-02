require 'test_helper'

module GtfsApi
  
  class RouteTest < ActiveSupport::TestCase
  
    # it's ok For testing VALIDATORS 
    def fill_valid_route
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
      r = self.fill_valid_route
      r.io_id = nil
      assert r.invalid?
    end
    
    test "route short name present" do
      r = self.fill_valid_route
      r.short_name = nil
      assert r.invalid?
    end
    
    test "route long name present" do
      r = self.fill_valid_route
      r.long_name = nil
      assert r.invalid?
    end
  
    test "route type out of range" do
      r = self.fill_valid_route
      r.route_type = 9 # valid range is [0..7]
      assert r.invalid?
    end
    
    test "route color nil and length" do
      r = self.fill_valid_route
      r.color = nil
      assert r.valid?
      r.color = "1234567" # valid range is [0..F]
      assert r.invalid?
    end
    
    test "route text color nil and length" do
      r = self.fill_valid_route
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
      r = self.fill_valid_route
      r.save!
      r2 = self.fill_valid_route
      assert_raises ( ActiveRecord::RecordInvalid) {r2.save!}
      r3 = self.fill_valid_route
      r3.io_id="newValidPid"
      assert_nothing_raised(ActiveRecord::RecordInvalid) {r3.save!}
    end
    
    # check belongs_to agency
    # uses fixtures
    test 'belongs to agency' do
      
      r = Route.find_by io_agency_id:'_agency_one'
      assert_equal('_agency_one', r.agency.io_id )
      
      # _agency_one should have been linked to 2 routes
      a= Agency.find_by_io_id('_agency_one')
      assert_equal(2, a.routes.count)
    end
    
  
  end #class
end #module
