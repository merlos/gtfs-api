module GtfsApi
  class CalendarDate < ActiveRecord::Base
    
    #VALIDATIONS
    validates :date, presence: true
    validates :exception_type, presence: true, numericality: {only_integer: true, greater_or_equal_to: 1, less_or_equal_to: 2}
    
    # CONSTANTS
    #exception_types
    SERVICE_ADDED = 1
    SERVICE_REMOVED = 2
    
    has_many :trips, foreign_key: 'service_id'
  end
end
