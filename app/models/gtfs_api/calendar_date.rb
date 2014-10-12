module GtfsApi
  class CalendarDate < ActiveRecord::Base
    
    include GtfsApi::Io::Models::Concerns::Gtfsable
    set_gtfs_col :service_id
    set_gtfs_col :date
    set_gtfs_col :exception_type
    
    #VALIDATIONS
    validates :service_id,      presence: true
    validates :date,            presence: true
    validates :exception_type,  presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 2}
    validates :feed,            presence: true
    # ASSOCIATIONS  
    has_many :trips, foreign_key: 'service_id', primary_key: 'service_id'
    belongs_to :feed    
    
    # CONSTANTS
    #exception_types
    SERVICE_ADDED = 1
    SERVICE_REMOVED =2
    
    ExceptionTypes = {
      :service_added => SERVICE_ADDED,
      :service_removed => SERVICE_REMOVED
    }
    
  end
end
