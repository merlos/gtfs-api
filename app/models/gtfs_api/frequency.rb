module GtfsApi
  class Frequency < ActiveRecord::Base
    
    include GtfsApi::Concerns::Models::Concerns::Csvable
    set_gtfs_col :trip_id
    set_gtfs_col :start_time
    set_gtfs_col :end_time
    set_gtfs_col :headway_secs
    set_gtfs_col :exact_times
    
    # VALIDATIONS
    validates :trip_id, presence:true
    validates :start_time, presence: true
    validates :end_time, presence: true
    validates :headway_secs, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}
    validates :exact_times, numericality: {only_integer:true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    
    # ASSOCIATIONS 
    belongs_to :trip
    
    # CONSTANTS
    
    # exact_times
    NOT_EXACT = 0
    EXACT = 1
    
  end
end
