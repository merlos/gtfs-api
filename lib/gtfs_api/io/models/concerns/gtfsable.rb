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


#
# This concern helps a GtfsApi model to import and export from and to a GTFS Feed file
#
# TODO add docummentation of this Concern as it is important to understand the code
#
#
module GtfsApi
  module Io
    module Models
      module Concerns
        module Gtfsable
          extend ActiveSupport::Concern
          #
          # this variable is true if new_from_gtfs() is called
          # You can use it within model callbacks
          #
          #@from_gtfs_called

          def from_gtfs_called
            @from_gtfs_called ||= false
          end

          def from_gtfs_called=(val)
            @from_gtfs_called= val == true ? true : false
          end

          #
          # returns a hash with the cols of the row of the corresponding file.
          # It assigns to each key (column of the file) the value of the mapped
          #  attribute.
          #
          # To see how to map each column to an attribute @see set_gtfs_col
          #
          # It calls the hook after_to_gtfs_feed (gtfs_feed_row) which allows the
          # model to override the default assignation if necessary
          #
          # returns empty hash if there is no mapping
          def to_gtfs
            gtfs_feed_row = {}
            return gtfs_feed_row if self.class.gtfs_cols.nil?
            #rehash to gtfs feed
            self.class.gtfs_cols.each do |model_attr,feed_col|
              #call send because virt. attr can only be accessed like that
              col_value = self.send(model_attr)
              col_value = col_value.to_gtfs if (col_value.is_a?(Date) || col_value.is_a?(Time))
              gtfs_feed_row[feed_col] = col_value
            end
            self.after_to_gtfs(gtfs_feed_row)
          end

          # Hook. overwrite if required
          # it receives an standard mapping of the model attributes to gtfs feed columns
          # this method should be overridden if the default value of an attribute needs
          # to be processed. For example, a time or a date may be reformatted.
          #
          # it shall return the final gtfs_feed_row
          def after_to_gtfs (gtfs_feed_row)
            return gtfs_feed_row
          end

          #
          # Hook. This method is called after *_from_gtfs is called
          #
          # overwrite if required
          def after_from_gtfs(model_attr_hash)
          end
          #
          # GTFS Spec allows times > 24h, but rails does not. this is a parser
          # It is stored a time object with that has as 00:00:00 => '0000-01-01 00:00 +00:00(UTC)'
          # Times are always kept in UTC
          #
          # @param attribute_sym[Symbol] attribute that will be parsed
          # @param val[String] the time string in gtfs format, ex: 25:33:33 or Time objet
          #
          #
          # @TODO Think: if is it better to store it as an integer or timestamp?
          #
          def gtfs_time_setter(attribute_sym, val)
            if val.is_a? String
              t = Time.new_from_gtfs(val)
              if t.nil?
                errors.add(attribute_sym, :invalid)
                write_attribute(attribute_sym, val)
                return false
              end
              write_attribute(attribute_sym, t)
              return
            end
            write_attribute(attribute_sym, val)
          end


          module ClassMethods

            #
            # attribute that holds the feed association
            #
            @@gtfs_feed_attr = :feed

            # Hash with the relations between gtfs_api => gtfs_feed column names ordered by classes
            #
            # @example
            #   { "class1 => {
            #        :gtfs_api_col_name1 => :gtfs_feed_name
            #     },
            #     "class2" => {
            #     }
            #   }
            @@gtfs_cols = {}

            # a hash with the relation between the gtfs_api class name and gtfs_feed file name
            # @example
            # { "GtfsApi::Agency" => :agency }
            @@gtfs_files = {}



            #
            # Defines a map between GtfsApi model column name and the GTFS column spcecification.
            # Used for import and export
            #
            # @param model_name[Symbol] name of attr in the model
            # @param gtfs_feed_col[Symbol] name of the column in the GTFS feed specification. (optional)
            #
            # If model_name and gtfs_feed_col are equal you can skipt setting gtfs_feed_col
            #
            # @example
            #   class GtfsApi::Agency < ActiveRecord::Base
            #    include GtfsApi::Concerns::Models::Concerns::Gtfsable
            #     set_gtfs_col :name            # expected GTFS feed file column: name
            #     set_gtfs_col :example, :test  # expected GTFS feed file column: test
            #   end
            def set_gtfs_col (model_attr, gtfs_feed_col = nil )
              gtfs_feed_col = model_attr if gtfs_feed_col.nil?
              @@gtfs_cols[self] = {} if @@gtfs_cols[self].nil?
              @@gtfs_cols[self][model_attr] = gtfs_feed_col
            end

            # returns[Symbol] gtfs column for the model attribute
            def gtfs_col_for_attr(model_attr)
              @@gtfs_cols[self][model_attr]
            end

            #returns[Symbol] model attribute for the gtfs_col
            def attr_for_gtfs_col(gtfs_col)
              self.gtfs_attr[gtfs_col]
            end

            #
            # Use this method for to set the list of attributes that need to include the feed.prefix
            # during import.
            # @see default_feed_prefix_attr default value.
            # Example:
            #  class GtfsApi::Agency < ActiveRecord::Base
            #    include GtfsApi::Concerns::Models::Concerns::Gtfsable
            #     add_feed_prefix_to_attr [:io_id]
            #     ...
            # @param model_attr_arr[Array] array with the attribute symbols to which the prefix is added
            #
            def add_feed_prefix_to_attr (model_attr_arr)
              @@feed_prefix_attr[self] = model_attr_arr
            end
            #
            # sets the gtfs feed file name (without extension) linked to this class
            # Default value set is the plural of the containing class. Example Agency => :agencies
            #
            # @param gtfs_feed_file_sym[Symbol] name of the file
            # @example
            #  class GtfsApi::Agency < ActiveRecord::Base
            #    include GtfsApi::Concerns::Models::Concerns::Gtfsable
            #     set_gtfs_file :agency
            #     .
            #
            def set_gtfs_file (gtfs_feed_file_sym)
              @@gtfs_files[self] = gtfs_feed_file_sym
            end

            # Map of GtfsApi columns as keys and Gtfs feed column as values
            # :gtfs_api_col => :gtfs_feed_col
            def gtfs_cols
              @@gtfs_cols[self]
            end

            #
            # @return[Symbol] the gtfs file name symbol linked to this class
            #
            # if set_gtfs_file was not called, it returns the underscore class name
            # pluralized
            # Example: For the class GtfsApi::Agency it would return :agencies

            def gtfs_file
              @@gtfs_files[self] ||= self.to_s.split("::").last.underscore.pluralize.to_sym
            end

            #
            # @returns[String] the gtfs file name string linked to this class
            #
            # if set_gtfs_file was not calle => returns the underscore class name pluralized
            # Ex: For the class GtfsApi::Agency it would return agencies.txt
            #
            def gtfs_filename
              return self.gtfs_file.to_s + '.txt'
            end

            #
            # @return [array] list of associations between classes and filenames
            #
            def gtfs_files
              return @@gtfs_files
            end


            # map of gtfs_feed_col => gtfs_api_col
            def gtfs_attr
              @@gtfs_cols[self].invert unless @@gtfs_cols[self].nil?
            end

            # cols for all classes
            def gtfs_cols_raw
              @@gtfs_cols
            end

            #
            # This method rehashes a row from gtfs feed specs
            #
            # @example
            #  #row example
            #  csv_row = {:agency_id=>'M_MAD', :agency_name=>'Metro Madrid', ... }
            #  Agency.rehash_from_gtfs_feed(csv_ro)
            #  # output hash: {io_id: 'M_MAD", :name" => 'Metro Madrid'}
            #
            # @param csv_row[Hash] a row of one of the file feeds
            # @return [Hash]
            def rehash_from_gtfs(csv_row)
              model_attr_values = {}
              csv_row.each do |csv_col, val|
                model_attr_values[self.attr_for_gtfs_col(csv_col)] =  val if self.gtfs_cols.values.include? (csv_col)
              end
              return model_attr_values
            end


            # To create a new gtfsable object. It will assign to each gtfs_col defined
            # for this class to the model attributes.
            #
            #
            # One way to keep track of the gtfs objects that belong to a feed is by
            # having a belongs_to reference to another model.
            #
            #
            # Example:
            #
            #   class Agency < ActiveRecord::Base
            #     ...
            #     set_gtfs_col :agency_id
            #     belongs_to feed
            #     ...
            #   end
            #
            #   class Feed < ActiveRecord::Base
            #     has_many :agencies
            #     has_many :routes
            #     ...
            #   end
            #
            #   feed = Feed.find(1)
            #   csv_row = {agency_id: 'agency_id'}
            #   a = Agency.new_from_gtfs(csv_row, feed)
            #   puts a.agency_id
            #   # => agency_id
            #   puts a.feed_id
            #
            # @param csv_row row with gtfs_cols of the feed
            # @param feed feed object that will be asigned.
            #
            # It will set the variable @from_gtfs_called to true in the object instance.
            # Useful to use with active record callbacks, for example, if you need to do
            # something before saving only if it an imported object
            # in the model http://api.rubyonrails.org/classes/ActiveRecord/Callbacks.html
            #
            def new_from_gtfs(gtfs_feed_row, feed = nil)
              model_attr_hash = self.rehash_from_gtfs(gtfs_feed_row)
              obj = self.new(model_attr_hash)
              obj.from_gtfs_called = true
              if feed != nil
                obj.send( "#{@@gtfs_feed_attr}=", feed)
              end
              obj.after_from_gtfs(model_attr_hash)
              return obj
            end


            def self.extended(base)
              #force set the default file
              @@gtfs_files[self] = self.to_s.split("::").last.underscore.pluralize.to_sym
            end


          end #ClassMethods
        end
      end
    end
  end
end
