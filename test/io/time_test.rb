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
  
      test "can create a Time from a gtfs time string" do
        time_string = "25:10:40"
        t = Time.new_from_gtfs("25:10:40")
        assert_equal t, Time.new(0,1,2,1,10,40,'+00:00')
      end
  
      test "create Time from gtfs time returns nil" do
        t = Time.new_from_gtfs("caca")
        assert_nil t
      end
  
      test 'create Time zero' do
        t = Time.new_from_gtfs("00:00:00")
        assert_equal t, Time.gtfs_zero
      end
  
      test 'can convert Time to gtfs time string' do
        time_string = "25:10:40"
        t = Time.new_from_gtfs(time_string)
        assert_equal t.to_gtfs, time_string
      end
      
      test 'to_gtfs_time works well with numbers smaller than 10' do
        t = Time.new_from_gtfs('01:01:01')
        assert_equal t.to_gtfs, '01:01:01'
      end
     
    end
  end #Io  
end # GtfsApi
