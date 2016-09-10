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
  class Calendar < ActiveRecord::Base
    include GtfsApi::Io::Models::Concerns::Gtfsable


    set_gtfs_file :calendar
    set_gtfs_col :service_io_id, :service_id
    set_gtfs_col :monday
    set_gtfs_col :tuesday
    set_gtfs_col :wednesday
    set_gtfs_col :thursday
    set_gtfs_col :friday
    set_gtfs_col :saturday
    set_gtfs_col :sunday
    set_gtfs_col :start_date
    set_gtfs_col :end_date
    set_gtfs_cols_with_prefix [:service_id]


    # VALIDATIONS
    validates :service, presence:true
    validates :monday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :tuesday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :wednesday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :thursday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :friday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :saturday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :sunday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :start_date, presence: true
    validates :end_date, presence: true
    validates :feed, presence: true


    # ASSOCIATIONS
    belongs_to :service
    belongs_to :feed

    has_many :trips, foreign_key: 'service_id', primary_key: 'service_id'

    #VIRTUAL ATTRIBUTES
    attr_accessor :service_io_id
    attr_accessor :create_service_on_save

    def service_io_id
      self.service.present? ? self.service.io_id : nil
    end
    
    # searches for a service with io_id and assigns it to service
    # Initializes the variable @_service_io_id
    def service_io_id=(val)
      @_service_io_id = val
      self.service = Service.find_by(io_id: val)
    end

    before_validation(on: :create) do
      # if it was imported (ie: new_from_gtfs was caled) and the service associated does not exist
      # (service_io_id returns nill), then create the service.
      self.create_service_on_save = true if self.from_gtfs_called
      if @_service_io_id.present? && self.service == nil
        self.service = Service.create({io_id: @_service_io_id, feed: self.feed}) if self.create_service_on_save
      end
    end


    # CONSTANTS
    AVAILABLE = 1
    NOT_AVAILABLE = 0

    Available = {
      :yes => AVAILABLE,
      :no => NOT_AVAILABLE
    }

    Week = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
    WeekDays = [:monday, :tuesday, :wednesday, :thursday, :friday]
    Weekend = [:saturday, :sunday]
  end
end
