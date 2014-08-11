module GtfsApi
  class Calendar < ActiveRecord::Base
    
    include GtfsApi::Concerns::Models::Concerns::Csvable
    set_gtfs_col :io_id, :service_id
    set_gtfs_col :monday, :monday
    set_gtfs_col :tuesday, :tuesday
    set_gtfs_col :wednesday, :wednesday
    set_gtfs_col :thursday, :thursday
    set_gtfs_col :friday, :friday
    set_gtfs_col :saturday, :saturday
    set_gtfs_col :sunday, :sunday
    set_gtfs_col :start_date, :start_date
    set_gtfs_col :end_date, :end_date
    
    # Validations
    validates :io_id, uniqueness: true, presence:true #service_id
    validates :monday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :tuesday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :wednesday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :thursday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :friday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :saturday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :sunday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :start_date, presence: true
    validates :end_date, presence: true
    
    # ASSOCIATIONS  
    has_many :trips, foreign_key: 'service_id'
  
    # CONSTANTS
    SERVICE_AVAILABLE = 1
    SERVICE_NOT_AVAILABLE = 0
  
  end
end
