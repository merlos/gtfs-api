module GtfsApi
  class Transfer < ActiveRecord::Base
    
    # Validations
    validates :from_stop, presence: true
    validates :to_stop, presence: true
    validates :transfer_type, presence: true, numericality:  {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to:3}
    validates :min_transfer_time, numericality: {only_integer: true, greater_than_or_equal_to: 0}
    
    # Associations
    belongs_to :from_stop, class_name: 'Stop'
    belongs_to :to_stop, class_name: 'Stop'
    
    # Constants
    #transfer_types
    RECOMMENDED_TRANSFER = 0 #default
    TIMED_TRANSFER = 1
    MIN_TRANSFER_TIME_REQUIRED = 2
    TRANSFER_NOT_POSSIBLE = 3
    
    
    
  end
end
