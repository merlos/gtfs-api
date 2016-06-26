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
  class CalendarDate < ActiveRecord::Base

    include GtfsApi::Io::Models::Concerns::Gtfsable
    set_gtfs_col :service_io_id, :service_id
    set_gtfs_col :date
    set_gtfs_col :exception_type
    set_gtfs_cols_with_prefix [:service_id]

    #VALIDATIONS
    validates :service,         presence: true
    validates :date,            presence: true
    validates :exception_type,  presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 2}
    validates :feed,            presence: true


    # ASSOCIATIONS
    belongs_to :service
    has_many :trips, foreign_key: 'service_id', primary_key: 'service_id'
    belongs_to :feed


    #VIRTUAL ATTRIBUTES
    attr_accessor :service_io_id
    #undef :service_io_id if method_defined? :service_io_id
    def service_io_id
      service.present? ? service.io_id : nil
    end

    def service_io_id=(val)
      self.service = Service.find_by(io_id: val)
    end


    # CONSTANTS
    #exception_types
    SERVICE_ADDED = 1
    SERVICE_REMOVED =2

    ExceptionTypes = {
      :service_added => SERVICE_ADDED,
      :service_removed => SERVICE_REMOVED
    }
  end
end
