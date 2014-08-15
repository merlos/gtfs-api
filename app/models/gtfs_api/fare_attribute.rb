module GtfsApi
  class FareAttribute < ActiveRecord::Base
    
    include GtfsApi::Concerns::Models::Concerns::Gtfsable
    set_gtfs_col :io_id, :fare_id
    set_gtfs_col :price
    set_gtfs_col :currency_type
    set_gtfs_col :payment_method
    set_gtfs_col :tranfers
    set_gtfs_col :transfer_duration
    
    
    #valdations
    validates :io_id, uniqueness: true, presence:true
    validates :price, presence: true
    validates :currency_type, presence: true, length: {is: 3}
    validates :payment_method, presence: true, numericality: {only_integer: true, 
      greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
      
    validates :transfers, numericality: {only_integer: true, 
      greater_than_or_equal_to: 0, less_than_or_equal_to: 2}, 
      allow_nil: true
        
    validates :transfer_duration,numericality: {only_integer: true, 
      greater_than_or_equal_to: 0}, allow_nil: true
      # time in seconds
          
    #TODO validate that the currency code is corect
    # ISO4217
    # see this gem https://github.com/hexorx/currencies
    
    # Associations
    has_many :fare_rules, foreign_key:'fare_id'
    
    
    #payment_method
    PAID_ON_BOARD = 0
    PAID_BEFORE_BOARDING = 1
  
    #transfers
    NO_TRANSFERS = 0
    TRANSFER_ONCE = 1
    TRANSFER_TWICE = 2
    UNLIMITED_TRANSFERS = nil
    
  end
end
