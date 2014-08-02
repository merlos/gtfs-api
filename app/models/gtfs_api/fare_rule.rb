module GtfsApi
  class FareRule < ActiveRecord::Base
    
    validates :fare, presence: true
    validates :io_fare_id, presence: true
    # associations
    belongs_to :fare, foreign_key: 'fare_id', class_name: 'FareAttribute'
    belongs_to :route
    belongs_to :origin, foreign_key: 'origin_id', class_name: 'Stop', primary_key:'zone_id'
    belongs_to :destination, foreign_key: 'destination_id', class_name: 'Stop', primary_key: 'zone_id'
    belongs_to :contains, foreign_key: 'contains_id', class_name: 'Stop', primary_key: 'zone_id'

  end
end
