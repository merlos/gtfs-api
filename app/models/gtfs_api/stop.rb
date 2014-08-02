module GtfsApi
  class Stop < ActiveRecord::Base
    
    #validations
    validates :io_id, uniqueness: true, presence: true
    validates :name, presence: true
    validates :lat, presence: true, numericality: { greater_than: -90.000000, less_than: 90.000000}
    validates :lon, presence: true, numericality: {greater_than: -180.000000, less_than: 180.000000}
    validates :location_type, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    
    #associations
    belongs_to :parent_station, foreign_key: 'parent_station_id', class_name: 'Stop'
    
    has_many :stops, foreign_key: 'parent_station_id', class_name: 'Stop'
    
    # to get the fares this stop is the origin
    has_many :fares_as_origin, foreign_key: 'origin_id', primary_key: 'zone_id', class_name: 'FareRules'
    # to get the fares this stop is the destination
    has_many :fares_as_destination, foreign_key: 'destination_id', primary_key: 'zone_id', class_name: 'FareRules'
    # to get the fares this stop is contained
    has_many :fares_contained, foreign_key: 'contains_id', primary_key: 'zone_id', class_name: 'FareRules'
    # 0 or blank - Stop. A location where passengers board or disembark from a transit vehicle.
    #  1 - Station. A physical structure or area that contains one or more stop.
    STOP_TYPE = 0
    STATION_TYPE = 1
    
    has_many :transfers_from, foreign_key: 'to_stop_id', class_name: 'Transfers'
    has_many :transfers_to, foreign_key: 'to_stop_id', class_name: 'Transfers'
    
  end
end
