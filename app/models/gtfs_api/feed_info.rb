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
  class FeedInfo < ActiveRecord::Base
    include GtfsApi::Io::Models::Concerns::Gtfsable
    set_gtfs_file :feed_info
    set_gtfs_col :publisher_name, :feed_publisher_name
    set_gtfs_col :publisher_url, :feed_publisher_url
    set_gtfs_col :lang, :feed_lang
    set_gtfs_col :start_date, :feed_start_date
    set_gtfs_col :end_date, :feed_end_date
    set_gtfs_col :version, :feed_version


    #VALIDATIONS
    validates :publisher_name, presence: true
    validates :lang, presence: true
    validates :publisher_url, presence: true, :'gtfs_api/validators/url'=>true
    validates :feed, presence: true
    #TODO validate lang against BCP-47


    #ASSOCIATIONS
    belongs_to :feed
  end
end
