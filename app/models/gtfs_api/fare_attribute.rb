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
  class FareAttribute < ActiveRecord::Base
    include Iso4217::Validator

    include GtfsApi::Io::Models::Concerns::Gtfsable
    set_gtfs_col :io_id, :fare_id
    set_gtfs_col :agency_io_id, :agency_id
    set_gtfs_col :price
    set_gtfs_col :currency_type
    set_gtfs_col :payment_method
    set_gtfs_col :transfers
    set_gtfs_col :transfer_duration
    set_gtfs_cols_with_prefix [:fare_id, :agency_id]


    # VALIDATIONS
    validates :io_id, uniqueness: true, presence:true
    validates :price, presence: true
    validates :currency_type, presence: true, length: {is: 3}, iso4217Code: true
    validates :payment_method, presence: true, numericality: {only_integer: true,
      greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :transfers, numericality: {only_integer: true,
      greater_than_or_equal_to: 0, less_than_or_equal_to: 5},
      allow_nil: true
    validates :transfer_duration,numericality: {only_integer: true,
      greater_than_or_equal_to: 0}, allow_nil: true # time in seconds
    validates :feed, presence: true


    # ASSOCIATIONS
    belongs_to :agency
    belongs_to :feed

    has_many :fare_rules, foreign_key:'fare_id'


    # VIRTUAL ATTRIBUTES
    attr_accessor :agency_io_id

    #gets the agency.io_id (useful for import/export)
    def agency_io_id
      agency.present? ? agency.io_id : nil
    end

    # associates the agency to the route by providing the agency.io_id
    def agency_io_id=(val)
      self.agency = Agency.find_by(io_id: val)
    end


    # CONSTANTS

    #payment_method
    ON_BOARD = 0
    BEFORE_BOARDING = 1
    Payment = {
      :on_board => ON_BOARD,
      :before_boarding => BEFORE_BOARDING
    }

    #transfers
    NO = 0
    ONCE = 1
    TWICE = 2
    UNLIMITED = nil
    #extension
    THREE_TIMES = 3
    FOUR_TIMES = 4
    FIVE_TIMES = 5

    Transfers = {
      :no => NO,
      :once => ONCE,
      :twice => TWICE,
      # extension
      :three_times => THREE_TIMES,
      :four_times => FOUR_TIMES,
      :five_times => FIVE_TIMES,
      :unlimited => UNLIMITED
    }
  end
end
