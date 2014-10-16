
module GtfsApi
  module Io
    class DateTest < ActiveSupport::TestCase
      
      test 'to_gtfs' do
        t = Date.new(2014,06,20,)
        assert_equal '20140620', t.to_gtfs
      end
   
    end
  end
end
