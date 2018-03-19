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
        options = {prefix: nil, verbose: false }.merge(options)
        GtfsReader.config do
          return_hashes true
          verbose options[:verbose]
          sources do
            gtfs_api do
              agency_id = nil
              url feed_file
              #before { |etag| puts "Processing source with tag #{etag}..." }
              feed_definition &GtfsApi::Io::FeedDefinitionBlock
              handlers do
                @feed = GtfsApi::Feed.new({io_id: feed_file, source_url: feed_file, prefix: options[:prefix]})
                begin
                  @feed.save!
                rescue ActiveRecord::RecordInvalid => ex
                  puts ex
                  puts ex.record.errors
                end
                feed_info { |row|
                  puts "-**************************"
                  puts @feed
                  puts "-**************************"
                  Importer.import_one_row_of(GtfsApi::FeedInfo, row, @feed)
                }
                agency {|row|
                  if @feed.prefix != nil then
                    row[:agency_id] = @feed.prefix + row[:agency_id] if row[:agency_id]
                  end
                  Importer.import_one_row_of(GtfsApi::Agency,row, @feed)
                  if row[:agency_id].nil?
                    agency_id = GtfsApi::Agency.last.io_id
                    GtfsReader::Log.warn "agency_id not set for agency in agency.txt. auto assigned #{agency_id}"
                  end
                }
                routes {|row|
                  if row[:agency_id].nil?
                    GtfsReader::Log.warn "agency_id not set for routes. Auto assigned #{agency_id}"
                    row[:agency_id] = agency_id
                  end
                  Importer.import_one_row_of(GtfsApi::Route,row,@feed)
                }
                calendar {|row|
                  Importer.import_one_row_of(GtfsApi::Calendar,row, @feed)
                }
                calendar_dates{ |row|
                  Importer.import_one_row_of(GtfsApi::CalendarDate,row, @feed)
                }
                shapes { |row|
                  Importer.import_one_row_of(GtfsApi::Shape,row, @feed)
                }
                trips {|row|
                  Importer.import_one_row_of(GtfsApi::Trip, row, @feed)
                }
                stops { |row|
                  Importer.import_one_row_of(GtfsApi::Stop, row, @feed)
                }
                stop_times {|row|
                  Importer.import_one_row_of(GtfsApi::StopTime, row, @feed)
                }
                frequencies { |row|
                  Importer.import_one_row_of(GtfsApi::Frequency, row, @feed)
                }
                fare_attributes { |row|
                  if row[:agency_id].nil?
                    GtfsReader::Log.warn "agency_id not set for Fare Attributes. Assigned #{agency_id}"
                    row[:agency_id] = agency_id
                  end
                  Importer.import_one_row_of(GtfsApi::FareAttribute, row, @feed)
                }
                transfers { |row|
                  Importer.import_one_row_of(GtfsApi::Transfer, row, @feed)
                }
                fare_rules{ |row|
                  Importer.import_one_row_of(GtfsApi::FareRule, row, @feed)
                }
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
      # @param[GtfsApi::Feed] feed the row belongs to
      def self.import_one_row_of(gtfsable_class, row, to_feed = nil)
        a = gtfsable_class.new_from_gtfs(row, to_feed)
        if a.valid?
          begin
            a.save!
            id_str = (a.has_attribute? :io_id) ? a.io_id : a.id.to_s
            GtfsReader::Log.info "saved #{gtfsable_class.to_s} #{id_str}" #"saved #{a.io_id}"
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
