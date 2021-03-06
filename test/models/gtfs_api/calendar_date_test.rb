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
  class CalendarDateTest < ActiveSupport::TestCase

    # fills a valid model
    # @param feed [GtfsApi::Feed]
    def self.fill_valid_model (feed = nil)
      if feed.nil?
        feed = FeedTest.fill_valid_model
        feed.save!
      end
      service = ServiceTest.fill_valid_model feed
      service.save!
      return CalendarDate.new(
        service: service,
        date: '20140610',
        exception_type: CalendarDate::ExceptionTypes[:service_added],
        feed: feed
        )
    end

    # generates a valid gtfs_feed_row.
    #
    # if the test requires a feed use @see valid_gtfs_feed_row_for_feed
    def self.valid_gtfs_feed_row
      service = ServiceTest.fill_valid_model
      service.save!
      {
        service_id: service.io_id,
        date: '20140610',
        exception_type: CalendarDate::SERVICE_ADDED
      }
    end

    # generates a valid gtfs feed row for the feed argument
    # @param feed [GtfsApi::Feed] A feed.
    #
    # This method hall be used to create a row of a feed with prefix.
    # It creates the relations with the feed_id elements wich have the feed

    def self.valid_gtfs_feed_row_for_feed(feed)
      service = ServiceTest.fill_valid_model feed
      service.save!
      # io_id has the feed prefix, but when importing it does not have it
      service_id = service.io_id
      service_id = service_id.gsub(feed.prefix,'') if feed.prefix.present?
      #puts service_id
      {
        service_id: service_id,
        date: '20140610',
        exception_type: CalendarDate::SERVICE_ADDED
      }
    end


    def setup
      @model = CalendarDateTest.fill_valid_model
    end

    test "valid calendar date" do
      assert @model.valid?, @model.errors.to_a
    end

    test 'service_id required' do
      @model.service_id = nil
      assert @model.invalid?
    end

    test 'date required' do
      @model.date = nil
      assert @model.invalid?
    end

    test 'valid exception types' do
      @model.exception_type = CalendarDate::ExceptionTypes[:service_added]
      assert @model.valid?, @model.errors.to_a
      @model.exception_type = CalendarDate::ExceptionTypes[:service_removed]
      assert @model.valid?, @model.errors.to_a
    end

    test 'exception_type has to be greater than 0' do
      @model.exception_type = 0
      assert @model.invalid?
    end

    test 'exception_type has to be smaller than 3' do
      @model.exception_type = 3
      assert @model.invalid?
    end

    test "feed is required" do
      @model.feed = nil
      assert @model.invalid?
    end

    # ASSOCIATIONS

    test 'has many trips' do
      @model.save!
      t = TripTest.fill_valid_model
      t.service_id = @model.service_id
      assert t.valid?
      t.save!
      t2 = TripTest.fill_valid_model
      t2.service_id = @model.service_id
      assert t2.valid?
      t2.save!
      assert_equal @model.trips.size, Trip.where(service_id: @model.service_id).count
      @model.trips.each do |trip|
        assert_equal trip.service_id, @model.service_id
      end
    end

    #
    # GTFSABLE IMPORT/EXPORT
    #

    test "calendar_date row can be imported into a CalendarDate model" do
      model_class = CalendarDate
      test_class = CalendarDateTest
      exceptions = [:date] #exceptions to avoid test
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
    end

    test "calendar_date file row can be imported when feed has a prefix" do
      model_class = CalendarDate
      test_class = CalendarDateTest
      #--- common part
      generic_row_import_test_for_feed_with_prefix(model_class, test_class) # defined in test_helper
    end

    test "a CalendarDate model can be exported into a gtfs row" do
      model_class = CalendarDate
      test_class = CalendarDateTest
      exceptions = [:date]
      #------ Common_part
      model = test_class.fill_valid_model
      feed_row = model.to_gtfs
      model_class.gtfs_cols.each do |model_attr, feed_col|
        next if exceptions.include? (model_attr)
        assert_equal model.send(model_attr), feed_row[feed_col], "Testing " + model_attr.to_s + " vs " + feed_col.to_s
      end
    end

    #test the exception
    test 'date attribute import from gtfs row' do
      row = CalendarDateTest.valid_gtfs_feed_row
      feed = FeedTest.fill_valid_model
      feed.save!
      model = CalendarDate.new_from_gtfs(row, feed)
      assert_equal row[:date], model.date.to_gtfs
    end

    test 'date attribute export to gtfs_row' do
      row = @model.to_gtfs
      assert_equal @model.date.to_gtfs, row[:date]
    end


  end
end
