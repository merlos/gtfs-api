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
  class Frequency < ActiveRecord::Base

    include GtfsApi::Io::Models::Concerns::Gtfsable
    set_gtfs_col :trip_io_id, :trip_id
    set_gtfs_col :start_time
    set_gtfs_col :end_time
    set_gtfs_col :headway_secs
    set_gtfs_col :exact_times


    # VALIDATIONS
    validates :trip, presence: {message: :blank_or_not_found}
    validates :start_time, presence: true
    validates :end_time, presence: true
    validates :headway_secs, presence: true, numericality: {only_integer: true,
      greater_than_or_equal_to: 0}
    validates :exact_times, numericality: {only_integer:true,
      greater_than_or_equal_to: 0, less_than_or_equal_to: 1}, allow_nil: true
    validates :feed, presence: true


    # ASSOCIATIONS
    belongs_to :trip
    belongs_to :feed


    # VIRTUAL ATTRIBUTES
    attr_accessor :trip_io_id

    def trip_io_id
      trip.present? ? trip.io_id : nil
    end

    def trip_io_id=(val)
      self.trip = Trip.find_by(io_id: val)
    end

    def start_time=(val)
      gtfs_time_setter(:start_time, val)
    end

    def end_time=(val)
      gtfs_time_setter(:end_time, val)
    end


    # CONSTANTS
    # exact_times
    NOT_EXACT = 0
    EXACT = 1

    ExactTimes = {
      :not_exact => 0,
      :exact => 1
    }
  end
end
