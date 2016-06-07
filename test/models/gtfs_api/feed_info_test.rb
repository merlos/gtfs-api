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


    def self.fill_valid_model
      feed = FeedTest.fill_valid_model
      feed.save!

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
        lang: 'es',
        start_date: '20140620',
        end_date: '20150620',
        version: "V1.0"
      }
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



  end
end
