module GtfsApi
  class Frequency < ActiveRecord::Base
    
    include GtfsApi::Concerns::Models::Concerns::Gtfsable
    set_gtfs_col :trip_io_id
    set_gtfs_col :start_time
    set_gtfs_col :end_time
    set_gtfs_col :headway_secs
    set_gtfs_col :exact_times
    
    # VALIDATIONS
    validates :trip, presence:true
    validates :start_time, presence: true
    validates :end_time, presence: true
    validates :headway_secs, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}
    validates :exact_times, numericality: {only_integer:true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    
    # ASSOCIATIONS 
    belongs_to :trip
    
    # VIRTUAL ATTRIBUTES
    attr_accessor :trip_io_id
      
    def trip_io_id
      trip.present? ? trip.io_id : nil
    end
    
    def trip_io_id=(val)
      self.trip = Trip.find_by!(io_id: val)
    end
    
    # CONSTANTS
    
    # exact_times
    NOT_EXACT = 0
    EXACT = 1
    
    ExactTimes = {
      :not_exact => 0,
      :exact => 1
    }
    
  end
end
