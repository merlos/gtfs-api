module GtfsApi  
  class Stop < ActiveRecord::Base
    
    include GtfsApi::Io::Models::Concerns::Gtfsable
    #gtfs feed columns definitions
    set_gtfs_col :io_id, :stop_id
    set_gtfs_col :code, :stop_code
    set_gtfs_col :name, :stop_name
    set_gtfs_col :desc, :stop_desc
    set_gtfs_col :lat, :stop_lat
    set_gtfs_col :lon, :stop_lon
    set_gtfs_col :zone_id, :zone_id
    set_gtfs_col :url, :stop_url
    set_gtfs_col :location_type
    set_gtfs_col :parent_station_id, :parent_station
    set_gtfs_col :timezone, :stop_timezone
    set_gtfs_col :wheelchair_boarding
    #NON normative / GTFS Extension
    set_gtfs_col :vehicle_type
     
    
    #VALIDATIONS
    validates :io_id, uniqueness: true, presence: true
    validates :name, presence: true
    validates :lat, presence: true, numericality: { greater_than: -90.000000, less_than: 90.000000}
    validates :lon, presence: true, numericality: {greater_than: -180.000000, less_than: 180.000000}
    validates :url, allow_nil: true, :'gtfs_api/validators/url' => true
    validates :location_type, allow_nil: true, numericality: {only_integer: true, 
      greater_than_or_equal_to: 0, less_than_or_equal_to: 2}
    validates :wheelchair_boarding, allow_nil: true, numericality: {only_integer: true, 
      greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :vehicle_type, allow_nil: true, numericality: { only_integer: true, 
      greater_than_or_equal_to: 0, less_than_or_equal_to:1702 }
    validate :valid_vehicle_type
    validates :feed, presence: true
    # TODO
    # Validate timezone
    
    
    # ASSOCIATIONS
    belongs_to :parent_station, foreign_key: 'parent_station_id', class_name: 'Stop'
    
    has_many :stops, foreign_key: 'parent_station_id', class_name: 'Stop'
    
    # to get the fares this stop is the origin
    has_many :fares_as_origin, foreign_key: 'origin_id', primary_key: 'zone_id', class_name: 'FareRule'
    # to get the fares this stop is the destination
    has_many :fares_as_destination, foreign_key: 'destination_id', primary_key: 'zone_id', class_name: 'FareRule'
    # to get the fares this stop is contained
    has_many :fares_is_contained, foreign_key: 'contains_id', primary_key: 'zone_id', class_name: 'FareRule'
    
    has_many :stop_times
    #to get stop trips
    has_many :trips, through: 'stop_times'
    # to get transfers
    has_many :transfers_from, foreign_key: 'to_stop_id', class_name: 'Transfers'
    has_many :transfers_to, foreign_key: 'to_stop_id', class_name: 'Transfers'
    belongs_to :feed  
    
    
    # CONSTANTS 
    # Values for location_type
    # 0 or blank - Stop. A location where passengers board or disembark from a transit vehicle.
    #  1 - Station. A physical structure or area that contains one or more stop.
    STOP_TYPE = 0
    STATION_TYPE = 1
    ENTRANCE_TYPE = 2
    
    LocationTypes = {
      stop: 0,
      station: 1,
      entrance: 2
    }
    
    VehicleTypes = GtfsApi::Route::RouteTypes
     
    private 
    
    def valid_vehicle_type
      if vehicle_type.present?
        errors.add(:vehicle_type, :invalid) unless VehicleTypes.values.include? (vehicle_type)
      end
    end
  
  end
end
