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
                
                agency {|row| 
                  a = GtfsApi::Agency.new_from_gtfs_feed(row)
                  if a.valid?
                    a.save!
                    GtfsReader::Log.info "saved #{row}" #"saved #{a.io_id}" 
                  else 
                    GtfsReader::Log.error "problems in #{row}"
                    GtfsReader::Log.error a.errors.to_a 
                  end
                }
                
                routes {|row| 
                  puts "Read Route: #{row}" 
                }
                
                calendar {|row|
                  puts "Read Calendar"
                }
                
                calendar_dates{ |row|
                  puts "Read Calendar Dates"
                }
                
                shapes { |row|
                  puts "Read Shape:"
                }
                
                trips {|row| 
                  puts "Read trip: #{row[:trip_id]} #{row[:trip_short_name]}" 
                }
                stops { |row|
                  puts "Read stop" 
                }
                stop_times {
                  puts "Read Stop Times"
                }
                frequencies { |row|
                  puts "Read frequencies: "
                }
                
                fare_attributes {
                  puts "Read FareAttributes"
                }
                transfers {
                  puts "Read Transfer: "
                }
                fare_rules{|row| 
                  puts "Fare Rule for fare_id: #{row[:fare_id]}"
                }
              end #handlers
            end # sample
          end #sources
        end #config
        GtfsReader.update :gtfs_api # or GtfsReader.update_all!
      end
    end          
  end #io
end