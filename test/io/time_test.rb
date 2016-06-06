require 'test_helper'

module GtfsApi
  module Io
    #
    # a few methods were created to ease the conversion of GTFS times
    # these class tests those methods
    #
    class TimeTest < ActiveSupport::TestCase
      test "truth" do
        assert true
      end

      test 'is_gtfs_valid with a hour missing time 00:01' do
        assert_not Time.is_gtfs_valid? ('00:01')
      end

      test 'is_gtfs_valid with a valid time' do
        assert Time.is_gtfs_valid? ('44:30:31')
      end

      test 'time without hours returns nil' do
        t = Time.new_from_gtfs ("00:01")
        assert_nil t
      end

      test 'time with seconds greater than 59 returns nil' do
        t = Time.new_from_gtfs("00:00:99")
        assert_nil t, 'seconds set to 99 is not nil!'
        t = Time.new_from_gtfs("00:00:60")
        assert_nil t, 'seconds set to 60 is not nil!'
      end

      test 'time with minutes greater than 59 returns nil' do
        t = Time.new_from_gtfs("00:60:00")
        assert_nil t, 'minutes set to 60 does not return nil'
      end


      test "can create a time that has no exception" do
        t = Time.new_from_gtfs("10:11:12")
        assert_equal Time.new(0,1,1,10,11,12,'+00:00'), t
      end

      test "can create a time without trailing 0" do
        t = Time.new_from_gtfs("9:10:40")
        assert_equal Time.new(0,1,1,9,10,40,'+00:00'), t
      end

      test "can create a time with trailing 0" do
        t = Time.new_from_gtfs("09:10:40")
        assert_equal Time.new(0,1,1,9,10,40,'+00:00'), t
      end

      test "can create a Time from a gtfs time string greater than 24h" do
        time_string = "25:10:40"
        t = Time.new_from_gtfs("25:10:40")
        assert_equal Time.new(0,1,2,1,10,40,'+00:00'), t
      end

      test "create Time from gtfs time returns nil when format incorrect" do
        t = Time.new_from_gtfs("caca")
        assert_nil t
      end

      test 'create Time zero works fine' do
        t = Time.new_from_gtfs("00:00:00")
        assert_equal t, Time.gtfs_zero
      end

      test 'can convert Time to gtfs time string' do
        time_string = "25:10:40"
        t = Time.new_from_gtfs(time_string)
        assert_equal time_string, t.to_gtfs
      end

      test 'to_gtfs works well with numbers smaller than 10' do
        t = Time.new_from_gtfs('01:01:01')
        assert_equal '01:01:01', t.to_gtfs
      end

      test 'to_gtfs works well with time zero' do
        t = Time.gtfs_zero
        assert_equal '00:00:00', t.to_gtfs
      end

    end
  end #Io
end # GtfsApi
