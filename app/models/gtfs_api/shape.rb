module GtfsApi
  class Shape < ActiveRecord::Base
    validates :io_id, presence: true
    validates :pt_lat, presence: true, numericality: { greater_than: -90.000000, less_than: 90.000000}
    validates :pt_lon, presence: true, numericality: {greater_than: -180.000000, less_than: 180.000000}
    validates :pt_sequence, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}
    validates :dist_traveled, numericality: {greater_than_or_equal_to: 0}
    
    #associations
    has_and_belongs_to_many :trips, join_table: 'gtfs_api_trips', foreign_key: 'shape_id', association_foreign_key: 'id'
  end
end
