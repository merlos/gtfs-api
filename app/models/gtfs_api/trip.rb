module GtfsApi
  class Trip < ActiveRecord::Base
    
    #validation 
    validates :io_trip_id, uniqueness: true
    validates :route, presence: true
    validates :service_id, presence: true
    
    validates :direction_id, numericality: {only_integer: true, grater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :wheelchair_accesible, numericality: {only_integer: true, grater_than_or_equal_to: 0, less_than_or_equal_to: 2}    
    validates :wheelchair_accesible, numericality: {only_integer: true, grater_than_or_equal_to: 0, less_than_or_equal_to: 2}    
    
    
    #Associations
    has_and_belongs_to_many :shapes, join_table: 'gtfs_api_trips', foreign_key: 'shape_id', association_foreign_key: 'id'
    belongs_to :route
    belongs_to :calendar, foreign_key: 'service_id', class: 'Calendar'
    belongs_to :calendar_dates, foreign_key: 'service_id', class: 'CalendarDate' 
    
    #Constants 
    
    #Direction_id
    OUTBOUND_TRAVEL = 0
    INBOUND_TRAVEL = 1
    
    #Wheelchair and bike info
    NO_INFO = 0 #or nil
    YES = 1
    NO = 2
    
    
  end
end
