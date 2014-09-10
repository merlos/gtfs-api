require 'test_helper'

module GtfsApi
  class FareRuleTest < ActiveSupport::TestCase
     
    def self.fill_valid_fare_rule 
      unique = (0...8).map { (65 + rand(26)).chr }.join
      fa = FareAttribute.new(
        io_id: unique,
        price: 11.11,
        currency_type: 'EUR',
        payment_method: FareAttribute::ON_BOARD)
      fa.save!   
      
      r = RouteTest.fill_valid_route
      r.io_id = unique
      r.save!
      
      s_o = StopTest.fill_valid_stop
      s_o.zone_id = unique + "origin"
      s_o.save!
      
      s_d = StopTest.fill_valid_stop
      s_d.zone_id = unique + "destination"
      s_d.save!
      
      s_c = StopTest.fill_valid_stop
      s_c.zone_id = unique + "contains"
      s_c.save!
      
      return FareRule.new( 
        fare: fa,
        route: r,
        origin_id: s_c.zone_id,
        destination_id: s_d.zone_id,
        contains_id: s_c.zone_id)
    end
    
    
    def self.valid_gtfs_feed_fare_rule
      f = FareRuleTest.fill_valid_fare_rule
      return {
        fare_id: f.fare.io_id,
        route_id: f.route.io_id,
        origin_id: f.origin_id,
        destination_id: f.destination_id,
        contains_id: f.contains_id
      }
    end
    
    test 'a valid fare_rule is valid' do
      f = FareRuleTest.fill_valid_fare_rule
      assert f.valid?, f.errors.to_a
    end
     
    test 'fare_id presence required' do
      f = FareRuleTest.fill_valid_fare_rule
      f.fare = nil
      assert f.invalid?, f.errors.to_a       
    end
     
    test 'fare presence required' do
      f = FareRuleTest.fill_valid_fare_rule
      f.fare = nil
      assert f.invalid?
    end
     
    test 'route is optional' do
      f = FareRuleTest.fill_valid_fare_rule
      f.route = nil
      assert f.valid?  
    end
     
    test 'origin_id is optional' do
      f = FareRuleTest.fill_valid_fare_rule
      f.origin_id = nil
      assert f.valid?
    end
     
    test 'destination_id is optional' do
      f = FareRuleTest.fill_valid_fare_rule
      f.destination_id = nil
      assert f.valid?
    end
     
    test 'contains_id is optional' do
      f = FareRuleTest.fill_valid_fare_rule
      f.contains_id = nil
      assert f.valid?
    end
     
    test 'origin_id has to exit' do
      f = FareRuleTest.fill_valid_fare_rule
      f.origin_id = "bla bla"
      assert f.invalid?
    end
    
    test 'destination_id has to exist' do
      f = FareRuleTest.fill_valid_fare_rule
      f.destination_id = "bla bla"
      assert f.invalid? 
    end
    
    test 'contains_id has to exist' do
      f = FareRuleTest.fill_valid_fare_rule
      f.contains_id = "bla bla"
      assert f.invalid?
    end
     
    # Associations 
     
    test 'belongs to fare' do
        f = FareRuleTest.fill_valid_fare_rule
        assert_not f.fare.io_id.nil?
    end
    
    test 'belongs to route' do
      f = FareRuleTest.fill_valid_fare_rule
      assert_not f.route.io_id.nil?
    end
     
    test 'has_many origins associations returns the stops' do
      f = FareRuleTest.fill_valid_fare_rule
      assert (f.origins != nil)
      stops_where_num = Stop.where(zone_id: f.origin_id).count
      assert_equal f.origins.size, stops_where_num 
      f.origins.each do |record| 
        assert_equal record.zone_id, f.origin_id 
      end
    end
    
    test 'has_many destinations association returns the stops' do
      f = FareRuleTest.fill_valid_fare_rule
      assert (f.destinations != nil)
      stops_where_num = Stop.where(zone_id: f.destination_id).count
      assert_equal f.destinations.size, stops_where_num 
      f.destinations.each do |record| 
        assert_equal record.zone_id, f.destination_id 
      end 
    end
      
    test 'contains has_many association returns the expected stops' do
      f = FareRuleTest.fill_valid_fare_rule
      assert (f.contains != nil)
      stops_where_num = Stop.where(zone_id: f.contains_id).count
      assert_equal f.contains.size, stops_where_num 
      f.origins.each do |record| 
        assert_equal record.zone_id, f.contains_id 
      end
    end
      
    test 'virtual attribute route_io_id sets and gets route info' do
      f = FareRuleTest.fill_valid_fare_rule
      r = RouteTest.fill_valid_route
      r.io_id = "holitas"
      assert r.valid?
      r.save!
      assert_not_equal f.route.io_id, r.io_id 
      f.route_io_id = r.io_id
      assert_equal f.route.io_id, r.io_id
      assert_equal f.route_io_id, r.io_id
    end 
     
    test 'virtual attribute fare_io_id sets and gets fare info' do
      f = FareRuleTest.fill_valid_fare_rule
      fa = FareAttributeTest.fill_valid_fare_attribute
      fa.io_id = "holitas"
      assert fa.valid?
      fa.save!
      assert_not_equal f.fare.io_id, fa.io_id 
      f.fare_io_id = fa.io_id
      assert_equal f.fare.io_id, fa.io_id
      assert_equal f.fare_io_id, fa.io_id
    end
    
     #
     # requires fixtures with:
     #  - fare_rule that belongs_to a fare_attribute with io_id '_fare_one'
     test 'fare_rule belongs_to fare_attribute' do
       f = FareRuleTest.fill_valid_fare_rule
       fa = FareAttributeTest.fill_valid_fare_attribute
       fa.save!
       f.fare = fa
       f.save!
       
       f2 = FareRule.find(f.id)
       f2.fare.io_id
       assert_equal fa.io_id, f2.fare.io_id
     end
     
     
     test "fare_rule row can be imported into a FareRule model" do
       model_class = FareRule
       test_class = FareRuleTest
       exceptions = [] #exceptions, in test
       #--- common part
       feed_row = test_class.send('valid_gtfs_feed_' + model_class.to_s.split("::").last.underscore)
       #puts feed_row
       model = model_class.new_from_gtfs(feed_row)
       assert model.valid?
       model_class.gtfs_cols.each do |model_attr, feed_col|
         next if exceptions.include? (model_attr)
         assert_equal model.send(model_attr), feed_row[feed_col], "Testing " + model_attr.to_s + " vs " + feed_col.to_s
       end
       #------
     end
   
     test "a FareRule model can be exported into a gtfs row" do
       model_class = FareRule
       test_class = FareRuleTest
       exceptions = []
       #------ Common_part
       model = test_class.send('fill_valid_' + model_class.to_s.split("::").last.underscore)
       feed_row = model.to_gtfs
       model_class.gtfs_cols.each do |model_attr, feed_col|
         next if exceptions.include? (model_attr)
         assert_equal model.send(model_attr), feed_row[feed_col], "Testing " + model_attr.to_s + " vs " + feed_col.to_s
       end
     end
     
  end
end
