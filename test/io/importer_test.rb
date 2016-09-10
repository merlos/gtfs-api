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
  module Io
    class ImporterTest < ActiveSupport::TestCase
      test "truth" do
        assert true
      end

      test 'feed with files_missing' do
        zip_file = Rails.root.join('../', 'fixtures', 'feeds', 'files_missing', 'gtfs_feed.zip').to_s
        assert_raises (GtfsReader::RequiredFilenamesMissing) {
          GtfsApi::Io::Importer.import zip_file, prefix: nil, verbose: false
        }
      end

      test 'feed with error in feed' do
        zip_file = Rails.root.join('../', 'fixtures','feeds', 'with_error', 'gtfs_feed.zip').to_s
          GtfsApi::Io::Importer.import zip_file, prefix: nil, verbose: false
        end

      # TODO count values are hardcoded
      test 'can import feed panama' do
        # set a temporal stdout
        #strIO = StringIO.new
        #std_ori = $stdout
        #$stdout = strIO
        zip_file = Rails.root.join('../', 'fixtures', 'feeds', 'panama', 'gtfs_feed.zip').to_s
        GtfsApi::Io::Importer.import zip_file, prefix: nil, verbose: false
        #assert_not $stdout.string.include?('ERROR'), $stdout.string
        #set back standar output
        #$stdout = std_ori
        #count feeds
        assert_equal 1, Feed.count
        #puts Feed.all.inspect
        #count agencies
        assert_equal 2, Agency.count
        #count routes agency1
        assert_equal 1, Route.where('agency_id = 1').count
        # count routes agency 2
        assert_equal 1, Route.where('agency_id = 2').count
        # count calendar_date
        # N/A
        # count calendar
        assert_equal 3, Service.count
        # count routes
        assert_equal 2, Route.count
        # count stop times
        assert_equal 18, StopTime.count
        # count stops
        assert_equal 9, Stop.count
        #count all trips
        assert_equal 4, Trip.count
      end

      test 'can set an agency id automatically' do
        # TODO
        #strIO = StringIO.new
        #std_ori = $stdout
        #$stdout = strIO
        zip_file = Rails.root.join('../', 'fixtures', 'feeds', 'no_agency_id', 'gtfs_feed.zip').to_s
        GtfsApi::Io::Importer.import zip_file, prefix: nil, verbose: false
        # check everything went ok
        assert Agency.first.io_id
      end

      # TODO implementation
      test 'can set a prefix for a feed' do
        #strIO = StringIO.new
        #std = $stdout.clone
        #$stdout = strIO
        prefix = 'PREFIX_'
        zip_file = Rails.root.join('../','fixtures','feeds','panama','gtfs_feed.zip').to_s
        GtfsApi::Io::Importer.import zip_file, prefix: prefix, verbose: true
        # check everything went ok
        #assert_not $stdout.string.include?('ERROR'), $stdout.string
        #$stdout = std
        feed = Feed.find(1)
        puts feed.inspect
        assert_equal prefix, feed.prefix

        #
        assert feed.agencies.first.io_id.start_with? (prefix)
        assert feed.routes.first.io_id.start_with? (prefix)
        assert feed.calendars.first.service_io_id.start_with? (prefix)
        assert feed.calendar_dates.first.service_io_id.start_with? (prefix)
        assert feed.shapes.first.io_id.start_with? (prefix)
        assert feed.trips.first.io_id.start_with? (prefix)
        assert feed.stops.first.io_id.start_with? (prefix)
        assert feed.fare_attributes.first.io_id.start_with? (prefix)

      end
    end
  end
end
