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
  class FeedInfoTest < ActiveSupport::TestCase


    def self.fill_valid_model(feed = nil)
      if feed.nil? then
        feed = FeedTest.fill_valid_model
        feed.save!
      end
      FeedInfo.new( {
        publisher_name: "THE publisher",
        publisher_url: "http://gihub.com/merlos/gtfs_api",
        lang: 'es',
        start_date: '20140620',
        end_date: '20150620',
        version: 'V1.0',
        feed: feed
        })
    end


    def self.valid_gtfs_feed_row
      {
        feed_publisher_name: "Di publiser",
        feed_publisher_url: "http://github.com/merlos/gtfs_api",
        feed_lang: 'es',
        feed_start_date: '20140620',
        feed_end_date: '20400620',
        feed_version: "V1.0"
      }
    end


    def self.valid_gtfs_feed_row_for_feed(feed)
      self.valid_gtfs_feed_row
    end


    def setup
      @model =  FeedInfoTest.fill_valid_model
    end

    test 'valid feed info model' do
      assert @model.valid?
    end

    test 'publisher_name is required' do
      @model.publisher_name = nil
      assert @model.invalid?
    end

    test 'lang is required' do
      @model.lang = nil
      assert @model.invalid?
    end

    test 'url has to be a valid http url' do
      @model.publisher_url = "ftp://caca_de_vaca.com"
      assert @model.invalid?
    end

    test 'start_date is optional' do
      @model.start_date = nil
      assert @model.valid?
    end

    test 'end date is optional' do
      @model.end_date = nil
      assert @model.valid?
    end

    test 'version is optional' do
      @model.version = nil
      assert @model.valid?
    end


    #
    # GTFSABLE IMPORT/EXPORT
    #
    test "feed_info row can be imported into a FeedInfo model" do
      model_class = GtfsApi::FeedInfo
      test_class = GtfsApi::FeedInfoTest
      exceptions = [:start_date,:end_date] #exceptions, in test
      generic_row_import_test(model_class, test_class, exceptions) # defined in test_helper
    end

    test "exceptions start_date and end_date when importing a FeedInfo model" do
      row = GtfsApi::FeedInfoTest.valid_gtfs_feed_row
      model = GtfsApi::FeedInfo.new_from_gtfs(row)
      model.inspect
      assert_equal row[:feed_start_date], model.start_date.to_gtfs
      assert_equal row[:feed_end_date], model.end_date.to_gtfs
    end

    # test import with feed prefix
    test "feed_info row can be imported into a FeedInfo model and with a feed with prefix" do
      model_class = GtfsApi::FeedInfo
      test_class = GtfsApi::FeedInfoTest
      exceptions = [:start_date,:end_date] #exceptions, in test
      generic_row_import_test_for_feed_with_prefix(model_class, test_class) # defined in test_helper
    end

    test "feed_info row can be exported into a row" do
      model_class = GtfsApi::FeedInfo
      test_class = GtfsApi::FeedInfoTest
      exceptions = [:start_date, :end_date]
      generic_model_export_test(model_class, test_class, exceptions) # defined in test_helper
    end


  end
end
