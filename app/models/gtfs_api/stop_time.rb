module GtfsApi
  class StopTime < ActiveRecord::Base
    include GtfsApi::Concerns::Models::Concerns::Gtfsable
    #gtfs feed columns definitions
    set_gtfs_col :trip_io_id, :trip_id
    set_gtfs_col :arrival_time
    set_gtfs_col :departure_time
    set_gtfs_col :stop_io_id, :stop_id
    set_gtfs_col :stop_sequence
    set_gtfs_col :stop_headsign
    set_gtfs_col :pickup_type
    set_gtfs_col :drop_off_type
    set_gtfs_col :dist_traveled, :shape_dist_traveled
    
    # VALIDATIONS
    validates :trip, presence: {message: :blank_or_not_found}

    #TODO validate that the 
    #presence of arrival_time and departure_time is only required on the first and last stop
    validate :arrival_time_and_departure_time_both_or_none_set
    validate :departure_time_is_after_arrival_time
    
    validates :stop, presence: {message: :blank_or_not_found}
    validates :stop_sequence, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}
    validates :dist_traveled, numericality: {greater_than_or_equal_to: 0}, allow_nil: true
    validates :pickup_type, numericality: {only_integer: true,  greater_than_or_equal_to: 0, less_than_or_equal_to: 3}, allow_nil: true
    validates :drop_off_type, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 3}, allow_nil: true
    
    def arrival_time_and_departure_time_both_or_none_set
      return if (arrival_time.nil? && departure_time.nil?)
      if arrival_time.nil?
        errors.add(:arrival_time, :set_both_times)
        return
      end
      if departure_time.nil?
        errors.add(:departure_time, :set_both_times) 
        return
      end
    end
      
    def departure_time_is_after_arrival_time
      return if (arrival_time.nil? || departure_time.nil?)
      errors.add(:departure_time, :must_be_after_arrival_time) if (arrival_time > departure_time)
    end
    # VIRTUAL ATTRIBUTES
    attr_accessor :stop_io_id
    attr_accessor :trip_io_id 
    
    # virtual attribute that provides the stop.io_id of this StopTime (if stop is set), nil in othercase
    def stop_io_id
      stop.present? ? stop.io_id : nil
    end
    
    # virtual attribute that sets the stop of this StopTime using as input the 
    # io_id of that Stop
    def stop_io_id=(val)    
      self.stop = Stop.find_by(io_id: val)
    end
    
    def trip_io_id
      trip.present? ? trip.io_id : nil
    end
    
    # virtual attribute that sets the trip of this StopTime using as input the 
    # io_id of that Trip
    def trip_io_id=(val)
      self.trip = Trip.find_by(io_id: val)
    end
    
    #
    # gtfs time string or utc time 
    # @see Gtfsable::gtfs_time_setter
    def arrival_time=(val)
      gtfs_time_setter(:arrival_time, val) 
    end
  
    #
    # @param val[mixed] gtfs time string or utc Time
    # @see Gtfsable::gtfs_time_setter
    def departure_time=(val)
      gtfs_time_setter(:departure_time, val)
    end
    

    
    # ASSOCIATIONS
    belongs_to :stop
    belongs_to :trip 
    
    # CONSTANTS
  
    PickupTypes = {
      :regular => 0,
      :no => 1,
      :phone_agency => 2,
      :coordinate_with_driver => 3
    } 
    DropOffTypes = {
      :regular => 0,
      :no => 1,
      :phone_agency => 2,
      :coordinate_with_driver => 3
    } 
    
    #pickup and drop off types
    REGULAR= 0 #default
    NO = 1
    PHONE_AGENCY = 2
    COORDINATE_WITH_DRIVER = 3
    

    
    
  end
end
