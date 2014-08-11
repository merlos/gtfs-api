module GtfsApi
  class FeedInfo < ActiveRecord::Base
    include GtfsApi::Concerns::Models::Concerns::Csvable
    set_gtfs_col :publisher_name, :feed_publisher_name
    set_gtfs_col :publisher_url, :feed_publisher_url
    set_gtfs_col :lang, :feed_lang
    set_gtfs_col :start_date, :feed_start_date
    set_gtfs_col :end_date, :feed_end_date
    set_gtfs_col :version, :feed_version
    
    #Validations
    
    
  end
end
