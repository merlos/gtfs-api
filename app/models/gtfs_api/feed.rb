module GtfsApi
  class Feed < ActiveRecord::Base
    
    #VALIDATIONS
    validates :io_id, presence: true, uniqueness: true
    validates :prefix, uniqueness: true
    validates :source_url, :'gtfs_api/validators/url' => true, allow_nil: true 
    
    
    # ASSOCIATIONS
    has_many :agencies
    has_many :calendar_dates
    has_many :calendars
    has_many :fare_attributes
    has_many :fare_rules
    has_many :feed_infos
    has_many :frequencies
    has_many :routes
    has_many :shapes
    has_many :stop_times
    has_many :stops
    has_many :transfers
    has_many :trips
    has_many :services
  end
  
end
