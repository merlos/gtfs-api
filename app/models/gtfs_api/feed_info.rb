module GtfsApi
  class FeedInfo < ActiveRecord::Base
    include GtfsApi::Concerns::Models::Concerns::Gtfsable
    set_gtfs_file :feed_info
    set_gtfs_col :publisher_name, :feed_publisher_name
    set_gtfs_col :publisher_url, :feed_publisher_url
    set_gtfs_col :lang, :feed_lang
    set_gtfs_col :start_date, :feed_start_date
    set_gtfs_col :end_date, :feed_end_date
    set_gtfs_col :version, :feed_version
    #GtfsApi only
    set_gtfs_col :io_id, :feed_id
    
    
    #Validations
    validates :publisher_name, presence: true
    validates :lang, presence: true
    validates :publisher_url, presence: true, :'gtfs_api/validators/url'=>true
    
    #TODO validate lang against BCP-47
    
    has_many :agencies, foreign_key: 'feed_id'
  end
end
