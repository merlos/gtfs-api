module GtfsApi
  class Route < ActiveRecord::Base
    
    include GtfsApi::Io::Models::Concerns::Gtfsable
    #gtfs feed columns definitions
    set_gtfs_col :io_id, :route_id
    set_gtfs_col :short_name, :route_short_name
    set_gtfs_col :long_name, :route_long_name
    set_gtfs_col :desc, :route_desc
    set_gtfs_col :route_type, :route_type
    set_gtfs_col :url, :route_url
    set_gtfs_col :color, :route_color
    set_gtfs_col :text_color, :route_text_color
    #NO NORMATIVE (extension)
    set_gtfs_col :agency_io_id, :agency_id
    
    validates :io_id, uniqueness: true, presence:true
    validates :route_type, presence: true, numericality: { only_integer: true, 
      greater_than_or_equal_to: 0, less_than_or_equal_to:1702 }
    validates :url, :'gtfs_api/validators/url' => true, allow_nil: true 
    validates :color, format: { with: /\A[a-f0-9]{6}\z/i }, allow_nil: true
    validates :text_color, format: { with: /\A[a-f0-9]{6}\z/i }, allow_nil: true
    validate :either_short_name_or_long_name_present
    validate :valid_route_type
    validates :feed, presence: true
    
    # asociations
    belongs_to :agency
    has_many :trips
    has_one :fare, class: "FareRules"
    belongs_to :feed  
    
    # Virtual Attributes 
    attr_accessor :agency_io_id 
    
    #gets the agency.io_id (useful for import/export)
    def agency_io_id
      agency.present? ? agency.io_id : nil
    end
    
    # associates the agency to the route by providing the agency.io_id
    def agency_io_id=(val)
      self.agency = Agency.find_by(io_id: val)
    end
    
    # ROUTE TYPES
    # https://developers.google.com/transit/gtfs/reference#routes_fields
    # @example 
    #   r = Route.new
    #   r.route_type = Route::TYPE_TRAM
    # 0 - Tram, Streetcar, Light rail. Any light rail or street level system within 
    #     a metropolitan area.
    # 1 - Subway, Metro. Any underground rail system within a metropolitan area.
    # 2 - Rail. Used for intercity or long-distance travel.
    # 3 - Bus. Used for short- and long-distance bus routes.
    # 4 - Ferry. Used for short- and long-distance boat service.
    # 5 - Cable car. Used for street-level cable cars where the cable runs beneath the car.
    # 6 - Gondola, Suspended cable car. Typically used for aerial cable cars where the 
    #     car is suspended from the cable.
    # 7 - Funicular. Any rail system designed for steep inclines.
    
    # Extended Route Types 
    # 
    #Route Type	Description	Supported?
        
    # List of route types (Spec)
    
    TRAM_TYPE   = 0
    SUBWAY_TYPE = 1
    RAIL_TYPE  = 2
    BUS_TYPE    = 3
    FERRY_TYPE  = 4
    CABLE_CAR_TYPE = 5
    GONDOLA_TYPE = 6   
    FUNICULAR_TYPE = 7  
    
    RouteTypes = {
      tram: TRAM_TYPE,
      subway: SUBWAY_TYPE,
      rail: RAIL_TYPE,
      bus: BUS_TYPE,
      ferry: FERRY_TYPE,
      cable_car: CABLE_CAR_TYPE,
      gondola: GONDOLA_TYPE,
      funicular: FUNICULAR_TYPE,
      #
      # Extended route types
      # https://support.google.com/transitpartners/answer/3520902?hl=en&ref_topic=3521316 
      # This list comes from the Hierarchical Vehicle Type (HVT) codes from the European TPEG 
      # Commented lines are the ones that Google Maps does not support.
      # BTW it makes sense not supporting some codes for alist of public transport agencies
      # last update: Sept 2014
      
      railway_service: 100,	#Railway Service	Yes
      high_speed_rail_service: 101,	#High Speed Rail Service	Yes
      long_distance_train: 102,	#Long Distance Trains	Yes
      inter_regional_rail_service: 103,	#Inter Regional Rail Service	Yes
      car_transport_rail_service: 104,	#Car Transport Rail Service	 
      sleeper_rail_service: 105,	#Sleeper Rail Service	Yes
      regional_rail_service: 106,	#Regional Rail Service	Yes
      tourist_railway_service: 107,	#Tourist Railway Service	Yes
      rail_shuttle: 108,	#Rail Shuttle (Within Complex)	Yes
      suburban_railway: 109,	#Suburban Railway	Yes
      #replacement_rail_service: 110,	#Replacement Rail Service	 
      #special_rail_service: 111,	#Special Rail Service	 
      #lorry_transport_rail_service: 112,	#Lorry Transport Rail Service	 
      #all_rail_services: 113,	#All Rail Services	 
      #cross_country_rail_service: 114,	#Cross-Country Rail Service	 
      #vehicle_transport_rail_service: 115,	#Vehicle Transport Rail Service	 
      #rack_and_pinion_railway: 116,	#Rack and Pinion Railway	 
      #additional_rail_service: 117,	#Additional Rail Service	 
      coach_service: 200,	#Coach Service	Yes
      international_coach_service: 201,	#International Coach Service	Yes
      national_coach_service: 202,	#National Coach Service	Yes
      #shuttle_coach_service: 203,	#Shuttle Coach Service	 
      regional_coach_service: 204,	#Regional Coach Service	Yes
      #special_coach_service: 205,	#Special Coach Service	 
      #sightseeing_coach_service: 206,	#Sightseeing Coach Service	 
      #tourist_coach_service: 207,	#Tourist Coach Service	 
      computer_coach_service: 208,	#Commuter Coach Service	Yes
      #all_coach_services: 209,	#All Coach Services	 
      #suburban_railway_service: 300,	#Suburban Railway Service	 
      urban_railway_service: 400,	#Urban Railway Service	Yes
      urban_metro_service: 401,	#Metro Service	Yes
      urban_underground_service: 402,	#Underground Service	Yes
      #urban_railway_service: 403,	#Urban Railway Service	 
      #all_urban_railway_services: 404,	#All Urban Railway Services	 
      monorail: 405,	#Monorail	Yes
      #metro_service: 500,	#Metro Service	 
      #underground_service: 600,	#Underground Service	 
      bus_service: 700,	#Bus Service	Yes
      regional_bus_service: 701,	#Regional Bus Service	Yes
      express_bus_service: 702,	#Express Bus Service	Yes
      #stopping_bus_service: 703,	#Stopping Bus Service	 
      local_bus_service: 704,	#Local Bus Service	Yes
      #night_bus_service: 705,	#Night Bus Service	 
      #post_bus_service: 706,	#Post Bus Service	 
      #special_needs_bus: 707,	#Special Needs Bus	 
      #mobility_bus_service: 708,	#Mobility Bus Service	 
      #mobility_bus_for_registered_disabled: 709,	#Mobility Bus for Registered Disabled	 
      #sightseeing_bus: 710,	#Sightseeing Bus	 
      #shuttle_bus: 711,	#Shuttle Bus	 
      #school_bus: 712,	#School Bus	 
      #school_and_public_service_bus: 713,	#School and Public Service Bus	 
      #rail_replacement_bus_service: 714,	#Rail Replacement Bus Service	 
      #demand_and_response_bus_service: 715,	#Demand and Response Bus Service	 
      #all_bus_services: 716,	#All Bus Services	 
      trolleybus_service: 800,	#Trolleybus Service	Yes
      tram_service: 900,	#Tram Service	Yes
      #city_tram_service: 901,	#City Tram Service	 
      #local_tram_service: 902,	#Local Tram Service	 
      #regional_tram_service: 903,	#Regional Tram Service	 
      #sightseeing_tram_service: 904,	#Sightseeing Tram Service	 
      #shuttle_tram_service: 905,	#Shuttle Tram Service	 
      #all_tram_services: 906,	#All Tram Services	 
      water_tansport_service: 1000,	#Water Transport Service	Yes
      #international_car_ferry_service: 1001,	#International Car Ferry Service	 
      #national_car_ferry_service: 1002,	#National Car Ferry Service	 
      #regional_car_ferry_service: 1003,	#Regional Car Ferry Service	 
      #local_car_ferry_service: 1004,	#Local Car Ferry Service	 
      #international_passenger_ferry_service: 1005,	#International Passenger Ferry Service	 
      #national_passenger_ferry_service: 1006,	#National Passenger Ferry Service	 
      #regional_passenger_ferry_service: 1007,	#Regional Passenger Ferry Service	 
      #local_passenger_ferry_service: 1008,	#Local Passenger Ferry Service	 
      #post_boat_service: 1009,	#Post Boat Service	 
      #train_ferry_service: 1010,	#Train Ferry Service	 
      #road_link_ferry_service: 1011,	#Road-Link Ferry Service	 
      #airport_link_ferry_service: 1012,	#Airport-Link Ferry Service	 
      #car_high_speed_ferry_service: 1013,	#Car High-Speed Ferry Service	 
      #passenger_high_speed_ferry_service: 1014,	#Passenger High-Speed Ferry Service	 
      #sightseeing_boat_service: 1015,	#Sightseeing Boat Service	 
      #school_boat: 1016,	#School Boat	 
      #cable_dranw_boat_service: 1017,	#Cable-Drawn Boat Service	 
      #reiver_bus_service: 1018,	#River Bus Service	 
      #scheduled_ferry_service: 1019,	#Scheduled Ferry Service	 
      #shuttle_ferry_service: 1020,	#Shuttle Ferry Service	 
      #all_water_transport_services: 1021,	#All Water Transport Services	 
      #air_service: 1100,	#Air Service	 
      #international_air_service: 1101,	#International Air Service	 
      #domestic_air_service: 1102,	#Domestic Air Service	 
      #intercontinental_air_service: 1103,	#Intercontinental Air Service	 
      #domestic_scheduled_air_service: 1104,	#Domestic Scheduled Air Service	 
      #shuttle_air_service: 1105,	#Shuttle Air Service	 
      #intercontinental_charter_air_service: 1106,	#Intercontinental Charter Air Service	 
      #international_charter_air_service: 1107,	#International Charter Air Service	 
      #round_trip_charter_air_service: 1108,	#Round-Trip Charter Air Service	 
      #sightseeing_air_service: 1109,	#Sightseeing Air Service	 
      #helicopter_air_service: 1110,	#Helicopter Air Service	 
      #domestic_charter_air_service: 1111,	#Domestic Charter Air Service	 
      #shengen_area_air_service: 1112,	#Schengen-Area Air Service	 
      #airship_service: 1113,	#Airship Service	 
      #all_air_services: 1114,	#All Air Services	 
      #ferry_service: 1200,	#Ferry Service	 
      telecabin_service: 1300,	#Telecabin Service	Yes
      #telecabin_service_bis: 1301,	#Telecabin Service	 
      #cable_car_service: 1302,	#Cable Car Service	 
      #elevator_service: 1303,	#Elevator Service	 
      #chair_lift_service: 1304,	#Chair Lift Service	 
      #drag_lift_service: 1305,	#Drag Lift Service	 
      #small_telecabin_service: 1306,	#Small Telecabin Service	 
      #all_telecabin_services:1307,	#All Telecabin Services	 
      funicular_service_hvt: 1400,	#Funicular Service	Yes
      #funicular_service_bis: 1401,	#Funicular Service	 
      #all_funicular_services: 1402,	#All Funicular Service	 
      taxi_service: 1500,	#Taxi Service	Yes
      communal_taxi_service: 1501,	#Communal Taxi Service	Yes
      #water_taxi_service: 1502,	#Water Taxi Service	 
      #rail_taxi_service: 1503,	#Rail Taxi Service	 
      #bike_taxi_service: 1504,	#Bike Taxi Service	 
      #licensed_taxi_service: 1505,	#Licensed Taxi Service	 
      #private_hire_service_vehicle: 1506,	#Private Hire Service Vehicle	 
      #all_taxi_services: 1507,	#All Taxi Services	 
      #self_drive: 1600,	#Self Drive	 
      #hire_car: 1601,	#Hire Car	 
      #hire_ban: 1602,	#Hire Van	 
      #hire_motorbike: 1603,	#Hire Motorbike	 
      #hire_cycle: 1604,	#Hire Cycle	 
      miscellaneous_service: 1700,	#Miscellaneous Service	Yes
      cable_car_hvt: 1701,	#Cable Car	Yes
      horse_dranw_carriage: 1702	#Horse-drawn Carriage	Yes
    }
    
    # VALIDATIONS
    private
    
    def valid_route_type
      errors.add(:route_type, :invalid) unless RouteTypes.values.include? (route_type)
    end
    
    def either_short_name_or_long_name_present
      return if short_name.present? || long_name.present?
      errors.add(:short_name, :short_and_long_name_blank)
      errors.add(:long_name, :short_and_long_name_blank)
    end
    
  end
end
