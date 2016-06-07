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
  class FareRuleTest < ActiveSupport::TestCase

    def self.fill_valid_model
      unique = (0...8).map { (65 + rand(26)).chr }.join
      feed = FeedTest.fill_valid_model
      feed.save!
      fa = FareAttributeTest.fill_valid_model
      fa.io_id = unique
      fa.save!

      r = RouteTest.fill_valid_model
      r.io_id = unique
      r.save!

      s_o = StopTest.fill_valid_model
      s_o.zone_id = unique + "origin"
      s_o.save!

      s_d = StopTest.fill_valid_model
      s_d.zone_id = unique + "destination"
      s_d.save!

      s_c = StopTest.fill_valid_model
      s_c.zone_id = unique + "contains"
      s_c.save!


      return FareRule.new(
        fare: fa,
        route: r,
        origin_id: s_c.zone_id,
        destination_id: s_d.zone_id,
        contains_id: s_c.zone_id,
        feed: feed)
    end


    def self.valid_gtfs_feed_row
      f = FareRuleTest.fill_valid_model
      return {
        fare_id: f.fare.io_id,
        route_id: f.route.io_id,
        origin_id: f.origin_id,
        destination_id: f.destination_id,
        contains_id: f.contains_id
      }
    end

    def setup
      @model = FareRuleTest.fill_valid_model
    end

    test 'a valid fare_rule is valid' do
      assert @model.valid?, @model.errors.to_a
    end

    test 'fare_id presence required' do
      @model.fare = nil
      assert @model.invalid?, @model.errors.to_a
    end

    test 'fare presence required' do
      @model.fare = nil
      assert @model.invalid?
    end

    test 'route is optional' do
      @model.route = nil
      assert @model.valid?
    end

    test 'origin_id is optional' do
      @model.origin_id = nil
      assert @model.valid?
    end

    test 'destination_id is optional' do
      @model.destination_id = nil
      assert @model.valid?
    end

    test 'contains_id is optional' do
      @model.contains_id = nil
      assert @model.valid?
    end

    test 'origin_id has to exit' do
      @model.origin_id = "bla bla"
      assert @model.invalid?
    end

    test 'destination_id has to exist' do
      @model.destination_id = "bla bla"
      assert @model.invalid?
    end

    test 'contains_id has to exist' do
      @model.contains_id = "bla bla"
      assert @model.invalid?
    end

    # Associations

    test 'belongs to fare' do
        assert_not @model.fare.io_id.nil?
    end

    test 'belongs to route' do
      assert_not @model.route.io_id.nil?
    end

    test 'has_many origins associations returns the stops' do
      assert (@model.origins != nil)
      stops_where_num = Stop.where(zone_id: @model.origin_id).count
      assert_equal @model.origins.size, stops_where_num
      @model.origins.each do |record|
        assert_equal record.zone_id, @model.origin_id
      end
    end

    test 'has_many destinations association returns the stops' do
      assert (@model.destinations != nil)
      stops_where_num = Stop.where(zone_id: @model.destination_id).count
      assert_equal @model.destinations.size, stops_where_num
      @model.destinations.each do |record|
        assert_equal record.zone_id, @model.destination_id
      end
    end

    test 'contains has_many association returns the expected stops' do
      assert (@model.contains != nil)
      stops_where_num = Stop.where(zone_id: @model.contains_id).count
      assert_equal @model.contains.size, stops_where_num
      @model.origins.each do |record|
        assert_equal record.zone_id, @model.contains_id
      end
    end

    test 'virtual attribute route_io_id sets and gets route info' do
      r = RouteTest.fill_valid_model
      r.io_id = "holitas"
      assert r.valid?
      r.save!
      assert_not_equal @model.route.io_id, r.io_id
      @model.route_io_id = r.io_id
      assert_equal @model.route.io_id, r.io_id
      assert_equal @model.route_io_id, r.io_id
    end

    test 'virtual attribute fare_io_id sets and gets fare info' do
      fa = FareAttributeTest.fill_valid_model
      fa.io_id = "holitas"
      assert fa.valid?
      fa.save!
      assert_not_equal @model.fare_io_id, fa.io_id
      @model.fare_io_id = fa.io_id
      assert_equal @model.fare.io_id, fa.io_id
    end

     #
     # requires fixtures with:
     #  - fare_rule that belongs_to a fare_attribute with io_id '_fare_one'
     test 'fare_rule belongs_to fare_attribute' do
       fa = FareAttributeTest.fill_valid_model
       fa.save!
       @model.fare = fa
       @model.save!

       f2 = FareRule.find(@model.id)
       assert_equal fa.io_id, f2.fare.io_id
     end

     #
     # GTFSABLE IMPORT/EXPORT
     #


     test "fare_rule row can be imported into a FareRule model" do
       model_class = FareRule
       test_class = FareRuleTest
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
         assert_equal model.send(model_attr), feed_row[feed_col], "Testing " + model_attr.to_s + " vs " + feed_col.to_s
       end
       #------
     end

     test "a FareRule model can be exported into a gtfs row" do
       model_class = FareRule
       test_class = FareRuleTest
       exceptions = []
       #------ Common_part
       model = test_class.fill_valid_model
       feed_row = model.to_gtfs
       model_class.gtfs_cols.each do |model_attr, feed_col|
         next if exceptions.include? (model_attr)
         assert_equal model.send(model_attr), feed_row[feed_col], "Testing " + model_attr.to_s + " vs " + feed_col.to_s
       end
     end

  end
end
