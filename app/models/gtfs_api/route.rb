module GtfsApi
  class Route < ActiveRecord::Base
    
    include GtfsApi::Concerns::Models::Concerns::Gtfsable
    #gtfs feed columns definitions
    set_gtfs_col :io_id, :route_id
    set_gtfs_col :agency_id
    set_gtfs_col :short_name, :route_short_name
    set_gtfs_col :long_name, :route_long_name
    set_gtfs_col :desc, :route_desc
    set_gtfs_col :route_type, :route_type
    set_gtfs_col :color, :route_color
    set_gtfs_col :text_color, :route_text_color
    
    
    
    validates :io_id, uniqueness: true, presence:true
    validates :short_name, presence: true
    validates :long_name, presence: true
    validates :route_type, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to:7 }
    validates :color, format: { with: /\A[a-f0-9]{6}\z/i }, allow_nil: true
    validates :text_color, format: { with: /\A[a-f0-9]{6}\z/i }, allow_nil: true
    # asociations
    belongs_to :agency
    has_many :trips
    has_one :fare, class: "FareRules"
    
    
    # TODO validate route_url
    #
    
    #
    # ROUTE TYPES
    # https://developers.google.com/transit/gtfs/reference#routes_fields
    #
    # 
    # @example 
    #   r = Route.new
    #   r.route_type = Route::TYPE_TRAM
    #
    #
    # 0 - Tram, Streetcar, Light rail. Any light rail or street level system within 
    #     a metropolitan area.
    TRAM_TYPE   = 0
    # 1 - Subway, Metro. Any underground rail system within a metropolitan area.
    SUBWAY_TYPE = 1
    # 2 - Rail. Used for intercity or long-distance travel.
    RAIL_TYPE  = 2
    # 3 - Bus. Used for short- and long-distance bus routes.
    BUS_TYPE    = 3
    # 4 - Ferry. Used for short- and long-distance boat service.
    FERRY_TYPE  = 4
    # 5 - Cable car. Used for street-level cable cars where the cable runs beneath the car.
    CABLE_CAR_TYPE = 5
    # 6 - Gondola, Suspended cable car. Typically used for aerial cable cars where the 
    #     car is suspended from the cable.
    GONDOLA_TYPE = 6   
    # 7 - Funicular. Any rail system designed for steep inclines.
    # List of route types
    FUNICULAR_TYPE = 7  
    
    
    
    
    
    
    
   
    
  end
end
