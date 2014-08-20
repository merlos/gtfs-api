require 'gtfs_reader'
require 'gtfs_api/io/feed_definition'

module GtfsApi
  module Io
    #
    # Imports a zip file / url into a GtfsApi datbase 
    #
    # usage sample:
    #
    #  GtfsApi::Importer.import('http://www.agency.com/gtfs_feed.zip')
    #  
    #  # if you are using a database that already has a feed, and you want to avoid id collision
    #  # you can use the prefix
    #  GtfsApi::Importer.import('http://www.agency.com/gtfs_feed.zip', 'agency_').
    #
    class Importer 
      #
      # imports a gtfs feed zip into the local database
      #
      # @param source[string] path/url to feed file
      # @param options[Hash] verbose(bool) and prefix (string)  
      #
      def self.import(feed_file, options = {})
        options = {prefix: '', verbose: false }.merge(options)
        GtfsReader.config do
          return_hashes true
          verbose options[:verbose]
          sources do
            gtfs_api do
              url feed_file
              #before { |etag| puts "Processing source with tag #{etag}..." }
              feed_definition &GtfsApi::Io::FeedDefinitionBlock
              handlers do
                agency {|row| Importer.import_one_row_of(GtfsApi::Agency,row) } 
                routes {|row| 
                  puts "#{row}"
                  Importer.import_one_row_of(GtfsApi::Route,row) }
                calendar {|row| Importer.import_one_row_of(GtfsApi::Calendar,row)}
                calendar_dates{ |row| Importer.import_one_row_of(GtfsApi::CalendarDate,row)}
                shapes { |row| Importer.import_one_row_of(GtfsApi::Shape,row)}
                trips {|row| Importer.import_one_row_of(GtfsApi::Trip, row)}
                stops { |row| Importer.import_one_row_of(GtfsApi::Stop, row)}
                stop_times { Importer.import_one_row_of(GtfsApi::StopTime, row)}
                frequencies { |row| Importer.import_one_row_of(GtfsApi::Fequency, row)}
                fare_attributes { |row| Importer.import_one_row_of(GtfsApi::FareAttribute, row)}
                transfers { |row| Importer.import_one_row_of(GtfsApi::FareAttribute, row)}
                fare_rules{ |row| Importer.import_one_row_of(GtfsApi::FareRule, row)}
              end #handlers
            end # sample
          end #sources
        end #config
        GtfsReader.update :gtfs_api # or GtfsReader.update_all!
      end
      
      private
      #
      #
      # @param[Class] gtfsable_class is one of the GtfsApi model classes that implements the Gtfsable concern
      # @param[Hash] row read from the gtfs file linked to the class  
      def self.import_one_row_of(gtfsable_class, row)
        a = gtfsable_class.new_from_gtfs_feed(row)
        if a.valid?
          begin 
            a.save!
            GtfsReader::Log.info "saved #{row}" #"saved #{a.io_id}" 
          rescue Exception => e
            GtfsReader::Log.error e.message
            raise e
          end
        else 
          GtfsReader::Log.error a.errors.to_a 
          GtfsReader::Log.error "Row contents: #{row}"
        end
      end
    
    end          
  end #io
end