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

  class RouteTest < ActiveSupport::TestCase

    # it's ok For testing VALIDATORS
    def self.fill_valid_model
      feed = FeedTest.fill_valid_model
      feed.save!

      Route.new(
        io_id: 'route_' + Time.new.to_f.to_s,
        short_name:'short name',
        long_name: 'route_long_name',
        desc: "route description",
        route_type: Route::FUNICULAR_TYPE,
        url: 'http://github.com/merlos',
        color: 'FFCCDD',
        text_color: '000000',
        feed: feed
      )
    end

    def self.valid_gtfs_feed_row
      a = AgencyTest.fill_valid_model
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

    def setup
      @model = RouteTest.fill_valid_model
    end

    test "route io_id has to be present" do
      @model.io_id = nil
      assert @model.invalid?
    end

    test "is valid when route short name is present but not route long" do
      @model.short_name = nil
      assert @model.valid?
    end

    test "is valid when route long name is present but not route short name" do
      @model.long_name = nil
      assert @model.valid?
    end

    test "is invalid when neither long name nor short name are present" do
      @model.short_name = nil
      @model.long_name = nil
      assert @model.invalid?
    end

    test "route_types are defined and valid" do
      @model.route_type = Route::TRAM_TYPE
      assert @model.valid?
      @model.route_type = Route::SUBWAY_TYPE
      assert @model.valid?
      @model.route_type = Route::RAIL_TYPE
      assert @model.valid?
      @model.route_type = Route::BUS_TYPE
      assert @model.valid?
      @model.route_type = Route::FERRY_TYPE
      assert @model.valid?
      @model.route_type = Route::CABLE_CAR_TYPE
      assert @model.valid?
      @model.route_type = Route::GONDOLA_TYPE
      assert @model.valid?
      @model.route_type = Route::FUNICULAR_TYPE
      assert @model.valid?
    end

    test "route_type out of upper limit is invalid" do
      @model.route_type = 1703 # valid range is [0..1703]
      assert @model.invalid?
    end

    test "route_type has to be positive" do
      @model.route_type = -1
      assert @model.invalid?
    end

    test "route_type has to be in RouteTypes constant" do
       @model.route_type = 1250
       assert @model.invalid?
       assert (@model.errors.added? :route_type, :invalid)
    end
    test "url is optional" do
      @model.url = nil
      assert @model.valid?
    end

    test "http and https are valid url formats" do
      @model.url = "http://www.foofoofoo.es/blow"
      assert @model.valid?, @model.errors.to_a.to_s
      @model.url = "https://barbarba@model.es/drunk"
      assert @model.valid?, @model.errors.to_a.to_s
    end

    test "ftp addresses are an invalid url format" do
      @model.url = "ftp://www.fetepe.es"
      assert @model.invalid?
    end

    test 'absolute url is invalid format' do
      @model.url = "/rururutatata/cacadevaca"
      assert @model.invalid?
    end

    test "color attribute is optional" do
      @model.color = nil
      assert @model.valid?
    end

    test "color length cannot be less than 6" do
      @model.color = "12345"
      assert @model.invalid?
    end

    test "color legth cannot be larger than 6" do
      @model.color = "1234567"
      assert @model.invalid?
    end

    test "color has to be an hex value" do
      @model.color = "GGGGGG"
      assert @model.invalid?
    end

    test "text_color is optional" do
      @model.color = nil
      assert @model.valid?
    end
    test "text_color length cannot be less than 6" do
      @model.color = "12345"
      assert @model.invalid?
    end

    test "text_color length cannot be greater than 6" do
      @model.color="1234567"
      assert @model.invalid?
    end

    test "text_color character have to be in hex string" do
      @model.color="GGGGGG"
      assert @model.invalid?
    end

    # database stuff
    test "uniqueness of route" do
      @model.io_id = "route_66"
      @model.save!
      r2 = RouteTest.fill_valid_model
      r2.io_id = "route_66"
      assert r2.invalid?
      assert_raises ( ActiveRecord::RecordInvalid) {r2.save!}
    end

    # check belongs_to agency
    test 'belongs to agency' do
      a = AgencyTest.fill_valid_model
      a.io_id = "known_agency_id"

      @model.agency = a
      assert @model.valid?
      @model.save!
      # retrieve the saved route and check if agency is linked
      r2 = Route.find_by io_id: @model.io_id
      assert_equal a.io_id, r2.agency.io_id

    end

    test 'virtual attribute agency_io_id works properly' do
      a = AgencyTest.fill_valid_model
      assert a.valid?
      a.save!
      assert_equal @model.agency, nil #the route has no agency set
      assert_equal @model.agency_io_id, nil # agency_io_id is therefore nil
      @model.agency_io_id = a.io_id # by assigning the io_id we assign the agency as well
      assert_equal @model.agency.io_id, a.io_id
      assert @model.valid?
      @model.save!
      assert_equal @model.agency.io_id, a.io_id #check no I can access agency
    end

    #
    # GTFSABLE IMPORT/EXPORT
    #

    test "routes row can be imported into a Route model" do
      model_class = Route
      test_class = RouteTest
      exceptions = [] #exceptions to avoid test
      #--- common part
      feed_row = test_class.valid_gtfs_feed_row
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

    test "a Route model can be exported into a gtfs row" do
      model_class = Route
      test_class = RouteTest
      exceptions = []
      #------ Common_part
      model = test_class.fill_valid_model
      feed_row = model.to_gtfs
      model_class.gtfs_cols.each do |model_attr, feed_col|
        next if exceptions.include? (model_attr)
        assert_equal model.send(model_attr), feed_row[feed_col], "Testing " + model_attr.to_s + " vs " + feed_col.to_s
      end
    end



  end #class
end #module
