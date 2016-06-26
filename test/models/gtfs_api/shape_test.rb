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
  class ShapeTest < ActiveSupport::TestCase
    # test "the truth" do
    #   assert true
    # end

    def self.fill_valid_model(feed = nil)
      if feed.nil? then
        feed = FeedTest.fill_valid_model
        feed.save!
      end
      feed_prefix = feed.prefix.present? ? feed.prefix : ''

      return Shape.new(
      io_id: feed_prefix + 'unique',
      pt_lat: '30.1',
      pt_lon: '30.2',
      pt_sequence: 1,
      dist_traveled: 3.3,
      feed: feed
      )
    end

    def self.valid_gtfs_feed_row
      return {
      shape_id: 'unique',
      shape_pt_lat: '30.1',
      shape_pt_lon: '30.2',
      shape_pt_sequence: '1',
      shape_dist_traveled: '3.3'
      }
    end

    def self.valid_gtfs_feed_row_for_feed(feed)
      self.valid_gtfs_feed_row
    end

    def setup
      @model = ShapeTest.fill_valid_model
    end

    test 'valid shape' do
      assert @model.valid?
    end

    test 'io_id presence required' do
      @model.io_id = nil
      assert @model.invalid?
    end

    test 'pt lat presence required' do
      @model.pt_lat = nil
      assert @model.invalid?
    end

    test 'pt lon presence required' do
      @model.pt_lon = nil
      assert @model.invalid?
    end

    test 'pt lat lower range min is -90' do
      @model.pt_lat = -89.9999
      assert @model.valid?
      @model.pt_lat = -90.1
      assert @model.invalid?
    end

    test 'pt lat upper range max is 90' do
      @model.pt_lat = 89.99
      assert @model.valid?
      @model.pt_lat = 90.1
      assert @model.invalid?
    end

    test "pt lon lower range min is -180" do
      @model.pt_lon = -179.99
      assert @model.valid?
      @model.pt_lon = -180.1
      assert @model.invalid?
    end

    test "pt_long upper range max is 180" do
      @model.pt_lon = 179.99
      assert @model.valid?
      @model.pt_lon = 180.1
      assert @model.invalid?
    end

    test 'pt sequence presence is required' do
      @model.pt_sequence = nil
      assert @model.invalid?
    end

    test "pt sequence has to be positive" do
      @model.pt_sequence = 0
      assert @model.valid?

      @model.pt_sequence = -1
      assert @model.invalid?
    end

    test 'pt seq has to be an integer' do
      @model.pt_sequence = 1.1
      assert @model.invalid?
    end

    test 'dist_traveled is optional' do
      @model.dist_traveled = nil
      assert @model.valid?
    end

    test 'dist_traveled has to be positive' do
      @model.dist_traveled = -1.0
      assert @model.invalid?
    end

    test 'dist_traveled has to be a number' do
      @model.dist_traveled = "holitas"
      assert @model.invalid?
    end

    # ASSOCIATIONS

    #
    # GTFSABLE IMPORT/EXPORT
    #

    test "shape row can be imported into a Shape model" do
       model_class = Shape
       test_class = ShapeTest
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
       model_class = Shape
       test_class = ShapeTest
       exceptions = [] #exceptions, in test
       generic_row_import_test_for_feed_with_prefix(model_class, test_class)
     end


     test "a Shape model can be exported into a gtfs row" do
       model_class = Shape
       test_class = ShapeTest
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

  end
end
