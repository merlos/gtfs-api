require 'test_helper'

module GtfsApi
  class FeedTest < ActiveSupport::TestCase
 
    def self.fill_valid_feed 
      self.fill_valid_model
    end
    
    def self.fill_valid_model 
      Feed.new( {
        name: "feed name",
        url: "http://gihub.com/merlos/gtfs_api"
        })
    end
  end
end
