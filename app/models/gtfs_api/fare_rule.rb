module GtfsApi
  class FareRule < ActiveRecord::Base
    
    include GtfsApi::Concerns::Models::Concerns::Csvable
    set_gtfs_col :fare_id, :fare_id
    set_gtfs_col :route_id, :route_id
    set_gtfs_col :origin_id, :origin_id
    set_gtfs_col :destination_id, :destination_id
    set_gtfs_col :contains_id, :contains_id
    
    
    validates :fare_id, presence: true
    # associations
    belongs_to :fare, foreign_key: 'fare_id', class_name: 'FareAttribute'
    belongs_to :route
    belongs_to :origin, foreign_key: 'origin_id', class_name: 'Stop', primary_key:'zone_id'
    belongs_to :destination, foreign_key: 'destination_id', class_name: 'Stop', primary_key: 'zone_id'
    belongs_to :contains, foreign_key: 'contains_id', class_name: 'Stop', primary_key: 'zone_id'

  end
end
