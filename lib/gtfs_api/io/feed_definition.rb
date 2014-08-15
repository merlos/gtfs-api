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
        prefix :feed do
          col :publisher_name, required: true
          col :publisher_url,  required: true
          col :lang,           required: true
          col :start_date
          col :end_date
          col :version
        end
      end
      # does not require any file   
      file :agency, required: true do
        col :agency_id,                       unique: true, alias: :io_id
        prefix :agency do
          col :name,     required: true
          col :url,      required: true, alias: :cacadevaca
          col :timezone, required: true
          col :lang
          col :phone
          col :fare_url
        end
      end
      
      # requires agency
      file :routes, required: true do
        col :route_id,         required: true, unique: true, alias: :io_id
        prefix :route do
          col :short_name, required: true
          col :long_name,  required: true
          col :desc
          col :type,       required: true
          col :url
          col :color
          col :text_color
        end
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
        col :id,            required: true, alias: :io_id
        prefix :shape do
          col :pt_lat,        required: true
          col :pt_lon,        required: true
          col :pt_sequence,   required: true
          col :dist_traveled
        end
      end
      
      # requires routes
      file :trips, required: true do
        col :id,         required: true, unique: true, alias: :io_id
        prefix :trip do
          col :headsign
          col :short_name
          col :long_name
        end
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
        prefix :stop do
          col :code 
          col :name,     required: true
          col :desc
          col :lat,      required: true
          col :lon,      required: true
          col :url
          col :timezone
        end
        col :zone_id
        col :location_type
        col :parent_station, alias: :parent_station_id
        col :wheelchair_boarding 
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
     }
    #
    # This definition of the GTFS Feed
    #
    # it is a customized version of the GtfsReader 
    GtfsApiFeedDefinition = GtfsReader::Config::FeedDefinition.new.tap do |feed|
          feed.instance_exec &GtfsApi::Io::FeedDefinitionBlock
    end
  
     
 end #io
end