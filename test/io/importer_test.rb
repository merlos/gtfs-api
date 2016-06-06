require 'test_helper'

module GtfsApi
  module Io
    class ImporterTest < ActiveSupport::TestCase
      test "truth" do
        assert true
      end

      test 'feed with error' do

      end

      # TODO count values are hardcoded
      test 'can import feed panama' do
        # set a temporal stdout
        strIO = StringIO.new
        std = $stdout.clone
        $stdout = strIO
        zip_file = Rails.root.join('../','fixtures','feed_panama','gtfs_feed.zip').to_s
        GtfsApi::Io::Importer.import zip_file, prefix: nil, verbose: true
        assert_not $stdout.string.include?('ERROR'), $stdout.string
        #set back standar output
        $stdout = std
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
        strIO = StringIO.new
        std = $stdout.clone
        $stdout = strIO
        zip_file = Rails.root.join('../','fixtures','feed_panama','gtfs_feed.zip').to_s
        GtfsApi::Io::Importer.import zip_file, prefix: nil, verbose: true
        # check everything went ok
        assert_not $stdout.string.include?('ERROR'), $stdout.string
        $stdout = std
      end

      test 'can set a prefix for a feed' do
        strIO = StringIO.new
        std = $stdout.clone
        $stdout = strIO
        prefix = 'PREFIX_'
        zip_file = Rails.root.join('../','fixtures','feed_panama','gtfs_feed.zip').to_s
        GtfsApi::Io::Importer.import zip_file, prefix: prefix, verbose: true
        # check everything went ok
        assert_not $stdout.string.include?('ERROR'), $stdout.string

        $stdout = std
        feed = Feed.find(1)
        #puts feed.inspect
        assert_equal prefix, feed.prefix

        # TODO check prefix was added
        
      end
    end
  end
end
