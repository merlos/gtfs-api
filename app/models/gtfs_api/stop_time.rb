module GtfsApi
  class StopTime < ActiveRecord::Base
    include GtfsApi::Concerns::Models::Concerns::Gtfsable
    #gtfs feed columns definitions
    set_gtfs_col :trip_id
    set_gtfs_col :arrival_time
    set_gtfs_col :departure_time
    set_gtfs_col :stop_id
    set_gtfs_col :stop_sequence
    set_gtfs_col :strop_headsign
    set_gtfs_col :pickup_type
    set_gtfs_col :drop_off_type
    set_gtfs_col :shape_dist_traveled
    
    # VALIDATIONS
    validates :trip, presence: true

    #TODO test if times > 24h need to be handled in a different way
    # it seems that only mysql supports setting 25.50h as time, but postgres does not
    validates :arrival_time, presence: true
    validates :departure_time, presence: true
    validates :stop, presence: true
    validates :stop_sequence, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}
    validates :shape_dist_traveled, numericality: {greater_than_or_equal_to: 0}
  
    # ASSOCIATIONS
    belongs_to :stop
    belongs_to :trip 
    
    # CONSTANTS
    
    #pickup_type
    REGULAR_PICKUP = 0 #default
    NO_PICKUP = 1
    PHONE_AGENCY_PICKUP = 2
    COORDINATE_WITH_DRIVER_PICKUP = 3
    
    #drop_off_type 
    REGULAR_DROP_OFF = 0 #default
    NO_DROP_OFF = 1
    PHONE_AGENCY_DROP_OFF = 2
    COORDINATE_WITH_DRIVER_DROP_OFF = 3
    
  end
end
