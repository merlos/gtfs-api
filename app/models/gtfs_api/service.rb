module GtfsApi
  #
  # Service Schedule 
  #
  # This is a class to hold the relation
  # among calendar, calendar_dates and trips
  #
  # Has the value of service_id when exporting to a gtfs_feed
  class Service < ActiveRecord::Base
    validates :io_id, presence: true, uniqueness: true 
    validates :feed, presence: true
    
    
    #relations
    has_many :calendars, foreign_key: 'service_id'
    has_many :calendar_dates, foreign_key: 'service_id'
    has_many :trips, foreign_key: 'service_id'
    belongs_to :feed
  end
end
