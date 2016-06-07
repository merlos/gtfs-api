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
  class Transfer < ActiveRecord::Base
    include GtfsApi::Io::Models::Concerns::Gtfsable
    #gtfs feed columns definitions
    set_gtfs_col :from_stop_io_id, :from_stop_id
    set_gtfs_col :to_stop_io_id, :to_stop_id
    set_gtfs_col :transfer_type
    set_gtfs_col :min_transfer_time


    # VALIDATIONS
    validates :from_stop, presence: {message: :blank_or_not_found}
    validates :to_stop, presence: {message: :blank_or_not_found}
    validates :transfer_type, presence: true, numericality:  {only_integer: true,
       greater_than_or_equal_to: 0, less_than_or_equal_to:3}
    validates :min_transfer_time, numericality: {only_integer: true,
      greater_than_or_equal_to: 0}, allow_nil: true
    validates :feed, presence: true


    # ASSOCIATIONS
    belongs_to :from_stop, class_name: 'Stop'
    belongs_to :to_stop, class_name: 'Stop'
    belongs_to :feed


    # VIRTUAL ATTRIBUTES
    attr_accessor :from_stop_io_id
    attr_accessor :to_stop_io_id

    def from_stop_io_id
      from_stop.present? ? from_stop.io_id : nil
    end

    def from_stop_io_id=(val)
      self.from_stop = Stop.find_by(io_id: val)
    end

    #Alternative implementation in case we want to allow to set nil
    #def from_stop_io_id=(val)
    #  stop = Stop.find_by(io_id: val)
    #  self.from_stop = stop ? stop : nil
    #end

    def to_stop_io_id
      to_stop.present? ? to_stop.io_id : nil
    end

    def to_stop_io_id=(val)
      self.to_stop = Stop.find_by(io_id: val)
    end


    # CONSTANTS
    #transfer_types
    RECOMMENDED_TRANSFER = 0 #default
    TIMED_TRANSFER = 1
    MIN_TRANSFER_TIME_REQUIRED = 2
    TRANSFER_NOT_POSSIBLE = 3

    TransferTypes = {
      recommended: 0,
      timed: 1,
      min_transfer_time_required: 2,
      not_possible: 3
    }
  end
end
