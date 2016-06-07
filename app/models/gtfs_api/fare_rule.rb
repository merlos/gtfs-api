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
  class FareRule < ActiveRecord::Base

    include GtfsApi::Io::Models::Concerns::Gtfsable
    set_gtfs_col :fare_io_id, :fare_id
    set_gtfs_col :route_io_id, :route_id
    set_gtfs_col :origin_id
    set_gtfs_col :destination_id
    set_gtfs_col :contains_id


    validates :fare_id, presence: {message: :blank_or_not_found}
    validate :origin_id_exists_if_set
    validate :destination_id_exists_if_set
    validate :contains_id_exists_if_set
    validates :feed, presence: true


    # ASSOCIATIONS
    belongs_to :fare, foreign_key: 'fare_id', class_name: 'FareAttribute'
    belongs_to :route
    belongs_to :feed

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
    def validate_stop_zone_id_exists(attribute_sym)
      if attribute_sym.present?
          errors.add(attribute_sym, :not_found) if Stop.find_by(zone_id: self[attribute_sym]).nil?
      end
    end
  end
end
