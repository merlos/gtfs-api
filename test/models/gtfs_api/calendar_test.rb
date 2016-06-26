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
  class CalendarTest < ActiveSupport::TestCase
    # test "the truth" do
    #   assert true
    # end
    week = ['monday', 'tuesday', 'wednesday','thursday', 'friday', 'saturday', 'sunday']

    def self.fill_valid_model (feed = nil)
      if feed.nil?
        feed = FeedTest.fill_valid_model
        feed.save!
      end
      service = ServiceTest.fill_valid_model feed
      return Calendar.new(
      service: service,
      monday: 1,
      tuesday: 1,
      wednesday: 1,
      thursday: 1,
      friday: 1,
      saturday: 1,
      sunday: 1,
      start_date: '20140722',
      end_date: '20140723',
      feed: feed)
    end

    def self.valid_gtfs_feed_row (feed = nil)
      service = ServiceTest.fill_valid_model(feed)
      service.save!
      {
        service_id: service.io_id,
        monday: "1",
        tuesday: "1",
        wednesday: "1",
        thursday: "1",
        friday: "1",
        saturday: "1",
        sunday: "1",
        start_date: '20140722',
        end_date: '20140723'
      }
    end

    def self.valid_gtfs_feed_row_for_feed(feed)
      row = self.valid_gtfs_feed_row feed
      #removes the prefix from the row, as the prefix is
      row[:service_id] = row[:service_id].gsub(feed.prefix,'') if feed.prefix.present?
      return row
    end


    def setup
      @model = CalendarTest.fill_valid_model
    end

    test 'valid calendar' do
      assert @model.valid?, @model.errors.to_a
    end


    test 'presence of days is required' do
      week.each do |d|
        c = CalendarTest.fill_valid_model
        c[d]= nil
        assert c.invalid?
      end
    end

    test 'upper range of week days' do
      week.each do |d|
        c = CalendarTest.fill_valid_model
        c[d]= 2
        assert c.invalid?
      end
    end

    test 'available is a valid value of week days' do
      week.each do |d|
        c = CalendarTest.fill_valid_model
        c[d]=Calendar::AVAILABLE
        assert c.valid?, c.errors.to_a
      end
    end

    test 'week days have to be integers' do
      week.each do |d|
        c = CalendarTest.fill_valid_model
        c[d]=0.5
        assert c.invalid?
      end
    end

    test 'not available is a valid value of week days' do
      week.each do |d|
        c = CalendarTest.fill_valid_model
        c[d]=Calendar::NOT_AVAILABLE
        assert c.valid?, c.errors.to_a
      end
    end

    test 'week day has to be positive' do
      week.each do |d|
        c = CalendarTest.fill_valid_model
        c[d]=-1
        assert c.invalid?
      end
    end

    test 'start_date presence required' do
      @model.start_date = nil
      assert @model.invalid?
    end

    test 'end_date presence required' do
      @model.end_date = nil
      assert @model.invalid?
    end

    # ASSOCIATIONS
    test 'calendar has many trips' do
      assert_equal 0, @model.trips.count
      @model.save!
      #assign this calendar to two trips
      t1 = TripTest.fill_valid_model
      t1.service = @model.service
      t1.save!

      t2 = TripTest.fill_valid_model
      t2.service = @model.service
      t2.save!
      # test that now the calendar has two trips linked
      assert_equal 2, @model.trips.count
    end

    #
    # GTFSABLE IMPORT/EXPORT
    #

    test "calendar row can be imported into a Calendar model" do
      model_class = Calendar
      test_class = CalendarTest
      exceptions = [:start_date, :end_date] #exceptions, in test
      #--- common part
      feed = FeedTest.fill_valid_model
      feed.save!
      feed_row = test_class.valid_gtfs_feed_row
      model = model_class.new_from_gtfs(feed_row, feed)
      assert model.valid?, model.errors.to_a.to_s

      model_class.gtfs_cols.each do |model_attr, feed_col|
        next if exceptions.include? (model_attr)
        model_value = model.send(model_attr)
        model_value = model_value.to_s if model_value.is_a? Numeric
        model_value = model_value.to_gtfs if model_value.is_a? Time
        assert_equal feed_row[feed_col], model_value, "Testing " + model_attr.to_s + " vs " + feed_col.to_s
      end
       #------
    end

    test "calendar file row can be imported when feed has a prefix" do
      model_class = Calendar
      test_class = CalendarTest
      generic_row_import_test_for_feed_with_prefix(model_class, test_class) # defined in test_helper
    end

    test "a Calendar model can be exported into a gtfs row" do
      model_class = Calendar
      test_class = CalendarTest
      exceptions = [:start_date, :end_date]
      #------ Common_part
      model = test_class.fill_valid_model
      feed_row = model.to_gtfs
      #puts feed_row
      model_class.gtfs_cols.each do |model_attr, feed_col|
        next if exceptions.include? (model_attr)
        feed_value = feed_row[feed_col]
        feed_value = feed_value.to_f if model.send(model_attr).is_a? Numeric
        feed_value = Time.new_from_gtfs(feed_value) if model.send(model_attr).is_a? Time
        assert_equal model.send(model_attr), feed_value, "Testing " + model_attr.to_s + " vs " + feed_col.to_s
      end
    end

    # Test the exceptions while importing
    test "exceptions start_date and end_date when importing a Calendar model" do
      row = CalendarTest.valid_gtfs_feed_row
      model = Calendar.new_from_gtfs(row)
      assert_equal row[:start_date], model.start_date.to_gtfs
      assert_equal row[:end_date], model.end_date.to_gtfs
    end

    test "exceptions start_date and end_date when exporting a Calendar model" do
      model = CalendarTest.fill_valid_model
      row = model.to_gtfs
      assert_equal model.start_date.to_gtfs, row[:start_date]
      assert_equal model.end_date.to_gtfs, row[:end_date]
    end

    #
    # Auto Create service tests
    #
    test "by default a non existing service is not auto created" do
      @model.service_io_id = "service_not_exists"
      assert_equal nil, @model.service
      assert @model.invalid?
      @model.errors.clear
      assert_equal false, @model.save
    end

    test "create_service_on_save true, then  service is created" do
      @model.service_io_id = "service_not_exists"
      assert_equal nil, @model.service
      @model.create_service_on_save = true
      assert_equal true, @model.save
      s = Service.find_by(io_id: "service_not_exists")
      assert_equal s.io_id, @model.service.io_id
    end

    test "that if service_io_id was never called auto create does not work" do
      @model.service = nil
      @model.create_service_on_save = true
      assert_equal false, @model.save, "model was saved but service_io_id was never called"
      s = Service.find_by(io_id: "service_not_exists")
      assert_equal nil, s
    end

    test "service is created if it does not exist and calendar was created using new_from_gtfs" do
      row = CalendarTest.valid_gtfs_feed_row
      row[:service_id] = "this_service_does_not_exist"
      model = Calendar.new_from_gtfs(row)
      # as the service does not exist it was not assigned
      assert_equal nil, model.service
      # but the hook before_validation fills it
      assert true, model.save
      assert_equal row[:service_id], model.service.io_id
    end


  end
end
