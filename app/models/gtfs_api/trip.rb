# The MIT License (MIT)
#
# Copyright (c) 2016 Juan M. Merlos, panatrans.org
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

module GtfsApi
  class Trip < ActiveRecord::Base

    include GtfsApi::Io::Models::Concerns::Gtfsable
    set_gtfs_col :route_io_id, :route_id
    set_gtfs_col :service_io_id, :service_id
    set_gtfs_col :io_id, :trip_id
    set_gtfs_col :headsign, :trip_headsign
    set_gtfs_col :short_name, :trip_short_name
    set_gtfs_col :direction, :direction_id
    set_gtfs_col :block_id
    set_gtfs_col :shape_id
    set_gtfs_col :wheelchair_accesible
    set_gtfs_col :bikes_allowed
    set_gtfs_cols_with_prefix [:route_id, :service_id, :trip_id, :shape_id]


    # ASSOCIATIONS
    belongs_to :route
    belongs_to :service
    belongs_to :feed

    has_many :frequencies
    has_many :shapes, foreign_key: 'io_id', primary_key: 'shape_id'
    # TODO test has calendards through service
    # TODO review associations to shapes
    has_many :calendars, foreign_key: 'service_id', primary_key: 'service_id'
    has_many :calendar_dates, foreign_key: 'service_id', primary_key: 'service_id'

    # TODO test has_many stop_times
    has_many :stop_times
    #TODO test has many stops
    has_many :stops, through: 'stop_times'

    # VALIDATIONS
    validates :io_id, uniqueness: true
    validates :route, presence: true
    validates :service, presence: true
    validates :direction, allow_nil: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :wheelchair_accesible, allow_nil: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 2}
    validates :bikes_allowed, allow_nil: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 2}
    validate :shape_id_exists_if_set
    validates :feed, presence: true


    # VIRTUAL ATTRIBUTES
    attr_accessor :route_io_id
    attr_accessor :service_io_id

    def route_io_id
      route.present? ? route.io_id : nil
    end

    def route_io_id=(val)
      self.route = Route.find_by(io_id: val)
    end

    def service_io_id
      service.present? ? service.io_id : nil
    end

    def service_io_id=(val)
      self.service = Service.find_by(io_id: val)
    end


    # CONSTANTS
    # Direction_id
    OUTBOUND_TRAVEL = 0
    INBOUND_TRAVEL = 1
    Direction = {
      :outbound_travel => OUTBOUND_TRAVEL,
      :inbound_travel => INBOUND_TRAVEL
    }

    # Wheelchair and bike info
    NO_INFO = 0 #or nil
    YES = 1
    NO = 2

    WheelChairAccesible = {
      :no_info => NO_INFO,
      :yes => YES,
      :no => NO
    }

    BikesAllowed = {
      :no_info => NO_INFO,
      :yes => YES,
      :no => NO
    }


    private

    # Valdiates that the shape_id exists if the attribute has been set
    def shape_id_exists_if_set
      if shape_id.present?
        errors.add(:shape_id, :not_found) if Shape.find_by(io_id: shape_id).nil?
      end
    end
  end
end
