module GtfsApi
  class FareRule < ActiveRecord::Base
    
    include GtfsApi::Concerns::Models::Concerns::Gtfsable
    set_gtfs_col :fare_io_id, :fare_id
    set_gtfs_col :route_io_id, :route_id
    set_gtfs_col :origin_id
    set_gtfs_col :destination_id
    set_gtfs_col :contains_id
    
    
    validates :fare_id, presence: {message: :blank_or_not_found}
    validate :origin_id_exists_if_set
    validate :destination_id_exists_if_set
    validate :contains_id_exists_if_set
    
    # ASSOCIATIONS
    belongs_to :fare, foreign_key: 'fare_id', class_name: 'FareAttribute'
    belongs_to :route
    
    # TODO see which association  has more sense based on these examples
    # https://code.google.com/p/googletransitdatafeed/wiki/FareExamples
    #
    #belongs_to :origin, foreign_key: 'zone_id', class_name: 'Stop'
    #belongs_to :destination, foreign_key: 'zone_id', class_name: 'Stop'
    #belongs_to :contains, foreign_key: 'zone_id', class_name: 'Stop'
    
    has_many :origins, 
      foreign_key: 'zone_id', 
      class_name: 'Stop', 
      primary_key: 'origin_id'
      
    has_many :destinations, 
      foreign_key: 'zone_id', 
      class_name: 'Stop', 
      primary_key: 'destination_id'
      
    has_many :contains, 
      foreign_key: 'zone_id', 
      class_name: 'Stop', 
      primary_key: 'contains_id'
        
    # VIRTUAL ATTRIBUTES
    attr_accessor :fare_io_id
    attr_accessor :route_io_id 
    
    # virtual attribute that provides the fare.io_id of this FareRule (if fare is set), nil otherwise
    def fare_io_id
      fare.present? ? fare.io_id : nil
    end
    
    # virtual attribute that sets the fare of this FareRule using as input the 
    # io_id of that FareAttribute
    def fare_io_id=(val)
      self.fare = FareAttribute.find_by(io_id: val)
    end
    
    def route_io_id
      route.present? ? route.io_id : nil
    end
    
    def route_io_id=(val)
      self.route = Route.find_by(io_id: val)
    end
    
    #VALIDATIONS
    
    def origin_id_exists_if_set
      validate_stop_zone_id_exists(:origin_id) if origin_id.present?
    end
    
    def destination_id_exists_if_set
       validate_stop_zone_id_exists(:destination_id) if destination_id.present?
    end
    
    def contains_id_exists_if_set
       validate_stop_zone_id_exists(:contains_id) if contains_id.present?
    end
    
    
    private

    # checks if the value of the attribute exists as zone_id in Stops
    # if the zone_id is not found, adds to the attriburte a :not_found 
    # validation error 
    #
    # @param attribute_sym[Symbol] attribute with the name of the zone_id(string)
    #
    def validate_stop_zone_id_exists(attribute_sym) 
      if attribute_sym.present?
          errors.add(attribute_sym, :not_found) if Stop.find_by(zone_id: self[attribute_sym]).nil?
      end
    end
        
  end
end
