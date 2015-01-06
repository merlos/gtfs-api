module GtfsApi
  class Shape < ActiveRecord::Base
    include GtfsApi::Io::Models::Concerns::Gtfsable
    #gtfs feed columns definitions
    set_gtfs_col :io_id, :shape_id
    set_gtfs_col :pt_lat, :shape_pt_lat
    set_gtfs_col :pt_lon, :shape_pt_lon
    set_gtfs_col :pt_sequence, :shape_pt_sequence
    set_gtfs_col :dist_traveled, :shape_dist_traveled 
    
    
    # VALIDATIONS
    validates :io_id, presence: true
    validates :pt_lat, presence: true, numericality: { greater_than: -90.000000, less_than: 90.000000}
    validates :pt_lon, presence: true, numericality: {greater_than: -180.000000, less_than: 180.000000}
    validates :pt_sequence, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}
    validates :dist_traveled, numericality: {greater_than_or_equal_to: 0}, allow_nil: true
    validates :feed, presence: true
    
    
    # ASSOCIATIONS
    has_and_belongs_to_many :trips, join_table: 'gtfs_api_trips', foreign_key: 'shape_id', association_foreign_key: 'io_id'
    belongs_to :feed  
  end
end
