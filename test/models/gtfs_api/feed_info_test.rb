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
    
    
    # IMPORT /EXPORT
    
    
  end
end
