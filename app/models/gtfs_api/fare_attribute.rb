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
    ON_BOARD = 0
    BEFORE_BOARDING = 1
    
    Payment = {
      :on_board => ON_BOARD,
      :before_boarding => BEFORE_BOARDING
    }
  
    #transfers
    NO = 0
    ONCE = 1
    TWICE = 2
    UNLIMITED = nil
    
    Transfers = {
      :no => NO,
      :once => ONCE,
      :twice => TWICE,
      :unlimited => UNLIMITED
    }
    
  end
end
