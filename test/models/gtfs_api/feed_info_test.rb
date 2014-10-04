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
        version: 'V1.0'
        })
    end
    def self.valid_gtfs_feed_feed_info
      {
        feed_publisher_name: "Di publiser",
        feed_publisher_url: "http://github.com/merlos/gtfs_api",
        lang: 'es',
        start_date: '2014-06-20',
        end_date: '2015-06-20',
        version: "V1.0"
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
    
    
    # IMPORT /EXPORT
    
    
  end
end
