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
