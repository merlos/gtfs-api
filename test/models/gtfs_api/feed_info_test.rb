require 'test_helper'

module GtfsApi
  class FeedInfoTest < ActiveSupport::TestCase
    
    def self.fill_valid_feed_info 
      self.fill_valid_model
    end
    
    def self.fill_valid_model 
      FeedInfo.new( {
        publisher_name: "THE publisher",
        publisher_url: "http://gihub.com/merlos/gtfs_api",
        lang: 'es',
        start_date: '2014-06-20',
        end_date: '2015-06-20',
        version: 'V1.0',
        
        #gtfs api extension
        io_id: "feed_id" + Time.new.to_f.to_s,
        data_version: 10,
        })
    end
    def self.valid_gtfs_feed_feed_info
      {
        feed_publisher_name: "Di publiser",
        feed_publisher_url: "http://github.com/merlos/gtfs_api",
        lang: 'es',
        start_date: '2014-06-20',
        end_date: '2015-06-20',
        version: "V1.0",
        feed_id: 'feed_id' + Time.new.to_f.to_s,
        data_version: 10
      }
    end
    
    
    test 'valid feed info model' do
      fi = FeedInfoTest.fill_valid_model
      assert fi.valid?
      
    end
    
    test 'publisher_name is required' do
      fi = FeedInfoTest.fill_valid_model
      fi.publisher_name = nil
      assert fi.invalid?
    end
    
    test 'lang is required' do
      fi = FeedInfoTest.fill_valid_model
      fi.lang = nil
      assert fi.invalid?
    end
    
    test 'url has to be a valid http url' do
      fi = FeedInfoTest.fill_valid_model
      fi.publisher_url = "ftp://caca_de_vaca.com"
      assert fi.invalid?
    end
    
    test 'start_date is optional' do
      fi = FeedInfoTest.fill_valid_model
      fi.start_date = nil
      assert fi.valid? 
    end
    
    test 'end date is optional' do
      fi = FeedInfoTest.fill_valid_model
      fi.end_date = nil
      assert fi.valid? 
    end
    
    test 'version is optional' do
      fi = FeedInfoTest.fill_valid_model
      fi.version = nil
      assert fi.valid? 
    end
    
    test 'io_id is optional' do
      fi = FeedInfoTest.fill_valid_model
      fi.io_id = nil
      assert fi.valid? 
    end
    
    test 'data_version is optional' do
      fi = FeedInfoTest.fill_valid_model
      fi.io_id = nil
      assert fi.valid?
    end
    
    #ASSOCIATIONS
    
    test 'feed has many agencies' do
      fi = FeedInfoTest.fill_valid_model
      fi.save!
      
      a1 = AgencyTest.fill_valid_agency
      a1.feed = fi
      a1.save!
      
      a2 = AgencyTest.fill_valid_agency
      a2.feed = fi
      a2.save!
      # feed has two agencies linked to it
      assert_equal 2, fi.agencies.count
    end
    
    # IMPORT /EXPORT
    
    
  end
end
