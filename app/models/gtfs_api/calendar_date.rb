module GtfsApi
  class CalendarDate < ActiveRecord::Base
    
    include GtfsApi::Concerns::Models::Concerns::Gtfsable
    set_gtfs_col :io_id, :service_id
    set_gtfs_col :date
    set_gtfs_col :exception_type
    
    #VALIDATIONS
    validates :io_id, presence: true
    validates :date, presence: true
    validates :exception_type, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 2}
    
    # CONSTANTS
    #exception_types
    SERVICE_ADDED = 1
    SERVICE_REMOVED =2
    
    ExceptionTypes = {
      :service_added => SERVICE_ADDED,
      :service_removed => SERVICE_REMOVED
    }
    
    # GTFSABLE 
    
    def after_rehash_to_gtfs(gtfs_row)
      gtfs_row[:date] = self.date.to_gtfs
      return gtfs_row
    end
    
    
    has_many :trips, foreign_key: 'service_id', primary_key: 'io_id'
  end
end
