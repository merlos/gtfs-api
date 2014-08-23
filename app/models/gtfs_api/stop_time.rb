module GtfsApi
  class StopTime < ActiveRecord::Base
    include GtfsApi::Concerns::Models::Concerns::Gtfsable
    #gtfs feed columns definitions
    set_gtfs_col :trip_io_id
    set_gtfs_col :arrival_time
    set_gtfs_col :departure_time
    set_gtfs_col :stop_io_id
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
    validates :dist_traveled, numericality: {greater_than_or_equal_to: 0}
    validates :pickup_type, numericality: {only_integer: true,  greater_than_or_equal_to: 0, less_than_or_equal_to: 3}, allow_nil: true
    validates :drop_off_type, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 3}, allow_nil: true
    
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
      self.stop = Stop.find_by!(io_id: val)
    end
    
    def trip_io_id
      trip.present? ? trip.io_id : nil
    end
    
    # virtual attribute that sets the trip of this StopTime using as input the 
    # io_id of that Trip
    def trip_io_id=(val)
      self.trip = Trip.find_by!(io_id: val)
    end
    
    
    #
    # gtfs time string or utc time 
    # @see time_setter
    def arrival_time=(val)
      time_setter(:arrival_time, val)
    end
  
    #
    # @param val[mixed] gtfs time string or utc Time
    # @see time_setter
    def departure_time=(val)
      time_setter(:departure_time, val)
    end
    
    #
    # GTFS Spec allows times > 24h, but rails does not. this is a parser
    # It is stored a time object with that has as 00:00:00 => '0000-01-01 00:00 +00:00(UTC)'
    # Times are always kept in UTC
    #
    # @param attribute_sym[Symbol] attribute that will be parsed
    # @param val[String] the time string in gtfs format, ex: 25:33:33 or Time objet 
    #
    #
    # @TODO Think: it is better to store it as an integer or timestamp?
    # 
    def time_setter(attribute_sym, val) 
      if val.is_a? String
        #puts is a string => parse
        if (hh,mm,ss = val.scan(/^0?(\d+):([0-5][0-9]):([0-5][0-9])+$/)[0]).nil?
          self.errors.add(attribute_sym,:invalid)
          write_attribute(attribute_sym, val)
          return
        end
        parsed_val = Time.new(0,1,(hh.to_f/24).floor+1,hh.to_f%24,mm,ss,'+00:00') #save utc 
        write_attribute(attribute_sym, parsed_val)
        return
      end
      write_attribute(attribute_sym, val)
      
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
