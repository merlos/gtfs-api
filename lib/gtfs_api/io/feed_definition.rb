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




require 'gtfs_reader'

module GtfsApi
  module Io
    #
    # This block defines the feed for Input and Output
    #
    # It is a gtfs-reader custom definition
    #
    FeedDefinitionBlock = Proc.new {
      #The order of the file definition is important because some models link others
      file :feed_info do
        col :feed_publisher_name, required: true
        col :feed_publisher_url,  required: true
        col :feed_lang,           required: true
        col :feed_start_date
        col :feed_end_date
        col :feed_version
      end
      # does not require any file
      file :agency, required: true do
        col :agency_id,                       unique: true, alias: :io_id
        col :agency_name,     required: true
        col :agency_url,      required: true, alias: :cacadevaca
        col :agency_timezone, required: true
        col :agency_lang
        col :agency_phone
        col :agency_fare_url
      end

      # requires agency
      file :routes, required: true do
        col :route_id,         required: true, unique: true, alias: :io_id
        col :route_short_name, required: true
        col :route_long_name,  required: true
        col :route_desc
        col :route_type,       required: true
        col :route_url
        col :route_color
        col :route_text_color
        col :agency_id
      end

      # does not require any file
      file :calendar, required: true do
        col :service_id, required: true, unique: true, alias: :io_id
        col :monday,    required: true
        col :tuesday,   required: true
        col :wednesday, required: true
        col :thursday,  required: true
        col :friday,    required: true
        col :saturday,  required: true
        col :sunday,    required: true
        col :start_date
        col :end_date
      end

      #does not require any file
      file :calendar_dates do
        col :service_id,     required: true, alias: :io_id
        col :date,           required: true
        col :exception_type, required: true
      end

      # does not require any file
      file :shapes do
        col :shape_id,            required: true, alias: :io_id
        col :shape_pt_lat,        required: true
        col :shape_pt_lon,        required: true
        col :shape_pt_sequence,   required: true
        col :shape_dist_traveled
      end

      # requires routes
      file :trips, required: true do
        col :trip_id,         required: true, unique: true, alias: :io_id
        col :trip_headsign
        col :trip_short_name
        col :trip_long_name
        col :route_id,              required: true
        col :service_id,            required: true
        col :direction_id
        col :block_id
        col :shape_id
        col :wheelchair_accessible
        col :bikes_allowed
      end

      # does not require any file
      file :stops, required: true do
        col :stop_id,       required: true, unique: true, alias: :io_id
        col :stop_code
        col :stop_name,     required: true
        col :stop_desc
        col :stop_lat,      required: true
        col :stop_lon,      required: true
        col :stop_url
        col :stop_timezone
        col :zone_id
        col :location_type
        col :parent_station, alias: :parent_station_id
        col :wheelchair_boarding
        col :vehicle_type
      end

      # requires stops and trips
      file :stop_times, required: true do
        col :trip_id,        required: true
        col :arrival_time,   required: true
        col :departure_time, required: true
        col :stop_id,       required: true
        col :stop_sequence, required: true
        col :stop_headsign
        col :pickup_type
        col :drop_off_type
        col :shape_dist_traveled
      end

      # requires trips
      file :frequencies do
        col :trip_id,      required: true
        col :start_time,   required: true
        col :end_time,     required: true
        col :headway_secs, required: true
        col :exact_times
      end

      # does not require any file
      file :fare_attributes do
        col :fare_id,        required: true, unique: true, alias: :io_id
        col :price,          required: true
        col :currency_type,  required: true
        col :payment_method, required: true
        col :transfers,      required: true
        col :transfer_duration
      end

      # requires stops
      file :transfers do
        col :from_stop_id,      required: true
        col :to_stop_id,        required: true
        col :transfer_type,     required: true
      end

      # requires fare_attributes, routes and stops
      file :fare_rules do
        col :fare_id,        required: true
        col :route_id
        col :origin_id
        col :destination_id
        col :contains_id
      end
    } # end proc
    #
    # This definition of the GTFS Feed
    #
    # it is a customized version of the GtfsReader
    GtfsApiFeedDefinition = GtfsReader::Config::FeedDefinition.new.tap do |feed|
      feed.instance_exec &GtfsApi::Io::FeedDefinitionBlock
    end
 end #io
end
