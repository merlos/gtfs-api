

#
# This concern helps a GtfsApi model to import and export from and to a GTFS Feed file
#
# TODO add docummentation of this Concern as it is important to understand the code
#
# 
module GtfsApi::Concerns::Models::Concerns::Gtfsable
    extend ActiveSupport::Concern
    
    #
    # returns a hash with the cols of the row of the corresponding file.
    # It assigns to each key (column of the file) the value of the mapped
    #  attribute. 
    #
    # To see how to map each column to an attribute @see set_gtfs_col
    #
    # It calls the hook after_rehash_to_gtfs_feed (gtfs_feed_row) which allows the
    # model to override the default assignation if necessary 
    #
    def to_gtfs
      gtfs_feed_row = {}
      #rehash to gtfs feed
      self.class.gtfs_cols.each do |model_attr,feed_col| 
        #call send because virt. attr can only be accessed like that
        col_value = self.send(model_attr) 
        col_value = col_value.to_gtfs if (col_value.is_a?(Date) || col_value.is_a?(Time))
        gtfs_feed_row[feed_col] = col_value
      end
      self.after_rehash_to_gtfs(gtfs_feed_row)
    end
    
    # overwrite if required
    # it receives an standard mapping of the model attributes to gtfs feed columns
    # this method should be overridden if the default value of an attribute needs
    # to be processed. For example, a time or a date may be reformatted.
    #
    # it shall return the final gtfs_feed_row
    def after_rehash_to_gtfs (gtfs_feed_row)
      return gtfs_feed_row
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
          self.errors.add(attribute_sym,:invalid)
          write_attribute(attribute_sym, val)
          return
        end
        write_attribute(attribute_sym, t)
        return
      end
      write_attribute(attribute_sym, val)
      
    end
    
    
    module ClassMethods
      
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
      # { ["GtfsApi::Agency"] => :agency }
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
      
      def gtfs_col_for_attr(model_attr)
        @@gtfs_cols[self][model_attr]
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
      # @return[Symbol] the gtfs_file name linked to this class
      # 
      def gtfs_file
        @@gtfs_files[self] ||= self.to_s.split("::").last.underscore.pluralize.to_sym
      end
      
      # map of gtfs_feed_col => gtfs_api_col
      def gtfs_attr
        @@gtfs_cols[self].invert
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
        to_gtfs_api = self.gtfs_attr
        csv_rehashed = Hash[csv_row.map {|gtfs_feed_col, v| 
          [to_gtfs_api[gtfs_feed_col],v]
          }
        ]
      end 
      
      def new_from_gtfs(csv_row)
        self.new(self.rehash_from_gtfs(csv_row)) 
      end 
      
        
    end #ClassMethods  
end
