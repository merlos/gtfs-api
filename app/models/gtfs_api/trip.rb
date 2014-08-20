module GtfsApi
  class Trip < ActiveRecord::Base
    
    include GtfsApi::Concerns::Models::Concerns::Gtfsable
    set_gtfs_col :route_id
    set_gtfs_col :service_id
    set_gtfs_col :io_id, :trip_id
    set_gtfs_col :headsign, :trip_headsign
    set_gtfs_col :short_name, :trip_short_name
    set_gtfs_col :direction_id
    set_gtfs_col :block_id
    set_gtfs_col :shape_id
    set_gtfs_col :wheelchair_accesible
    set_gtfs_col :bikes_allowed
    
    #Associations
    has_and_belongs_to_many :shapes, join_table: 'gtfs_api_trips', foreign_key: 'shape_id', association_foreign_key: 'io_id'
    belongs_to :route
    has_and_belongs_to_many :calendar, join_table: 'gtfs_api_trips', foreign_key: 'service_id', class: 'Calendar', association_foreign_key: 'io_id'
    has_and_belongs_to_many :calendar_dates, join_table: 'gtfs_api_trips', foreign_key: 'service_id', class: 'CalendarDate', association_foreign_key: 'io_id'
    has_many :frequencies
    
    #validation 
    validates :io_id, uniqueness: true
    validates :route, presence: true
    validates :service_id, presence: true
    
    validates :direction_id, allow_nil: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :wheelchair_accesible, allow_nil: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 2}  
    validates :bikes_allowed, allow_nil: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 2}  
    validate :shape_id_exists_if_set
    validate :service_id_exists_if_set
    
        
    # TODO review associations to calendar, calendar_dates and shapes
    
    #CONSTANTS
    #Direction_id
    OUTBOUND_TRAVEL = 0
    INBOUND_TRAVEL = 1
    
    #Wheelchair and bike info
    NO_INFO = 0 #or nil
    YES = 1
    NO = 2
    
    
    
    private
    
    #Validation methods
    
    #
    # Valdiates that the shape_id exists if the attribute has been set 
    def shape_id_exists_if_set
      if shape_id.present?
        errors.add(:shape_id, :not_found) if Shape.find_by(io_id: shape_id).nil?
      end
    end
    
    # Validates that service_id exists if set
    def service_id_exists_if_set
      if service_id.present?
        if Calendar.find_by(io_id: service_id).nil?
          errors.add(:service_id,:not_found) if CalendarDate.find_by(io_id: service_id).nil?
        end
      end
    end
    
    
  end
end
