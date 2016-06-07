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

    # TODO test the order
    has_many :stop_times, -> { order('stop_sequence ASC')}

    #to get stop trips
    has_many :trips, through: 'stop_times'
    # to get transfers
    has_many :transfers_from, foreign_key: 'to_stop_id', class_name: 'Transfers'
    has_many :transfers_to, foreign_key: 'to_stop_id', class_name: 'Transfers'
    belongs_to :feed

    # SCOPES
    #TODO test
    scope :ordered, -> { order('sequence ASC') }



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

    # TODO test
    def routes
      GtfsApi::Route.joins(trips: :stops).distinct.where(gtfs_api_stops: {id: self.id}).order('long_name ASC')
    end

    #
  # stops nearby the center of a position.
  # receives 3 params :lat, :lon, :radius
  #
  # BTW, it searchs within a square (efficiency)
  #
  def self.nearby (params)
    lat, lon, radius = params.values_at :lat, :lon, :radius
    # Not exact but easy. consider Earth a perfect sphere with a radius of 6371km
    # http://en.wikipedia.org/wiki/Longitude#Length_of_a_degree_of_longitude
    # http://en.wikipedia.org/wiki/Latitude#Meridian_distance_on_the_sphere
    #
    radius_lat = radius.to_f / 111194.9
    radius_lon = (radius.to_f / 111194.9) * Math::cos(lat.to_f).abs

    max_lat = lat.to_f + radius_lat
    min_lat = lat.to_f - radius_lat

    max_lon = lon.to_f + radius_lon
    min_lon = lon.to_f - radius_lon
    #Stop.where("lat > ? AND lat < ? AND lon > ? AND lon < ? ", min_lat, max_lat, min_lon, max_lon)
    Stop.where(lat: min_lat..max_lat, lon: min_lon..max_lon)
  end

  # TODO make test
  # export to Google Earth KML
  def self.to_kml
    kml = KMLFile.new
    folder = KML::Folder.new(name: 'Panatrans')
    all.each do |stop|
      folder.features << KML::Placemark.new(
          :name => stop.name,
        :geometry => KML::Point.new(coordinates: { lat: stop.lat, lng: stop.lon})
      )
    end
    kml.objects << folder
    kml.render
  end

  # TODO make test
  # export to gpx
  def self.to_gpx
    require 'GPX'
    gpx = GPX::GPXFile.new(name: 'Panatrans')
    all.each do |stop|
      gpx.waypoints << GPX::Waypoint.new({name: stop.name, lat: stop.lat, lon: stop.lon, time: stop.updated_at})
    end
    gpx.to_s
  end

  # TODO test
  # Distance from stop to point (straight line)
  # Example:
  #  @stop = stop.new({name: "name", lat: 0.0, lon: 1.1})
  #  @stop.distance_to(1.1, 2.2)
  #        => 172973.39717474958
  def distance_to(lat, lon)
    Haversine.distance(self.lat, self.lon, lat, lon).to_meters
  end

  private

    def valid_vehicle_type
      if vehicle_type.present?
        errors.add(:vehicle_type, :invalid) unless VehicleTypes.values.include? (vehicle_type)
      end
    end

  end
end
