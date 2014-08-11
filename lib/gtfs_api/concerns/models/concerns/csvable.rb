#
# This concern helps a GtfsApi model of a file in the GTFS spec to be imported and exported as csv
#
# In GtfsApi models these conventions were use for naming the columns:
# - Remove the innecessary prefix of the column names (ex: agency_name => name)
# - Exception of removing the prefix one exception, "route_type", which is kept as is, 
#   because type causes problems.
# - Many gtfs feed files use a string as id, that string is kept in => io_id     
# 
# 
module GtfsApi::Concerns::Models::Concerns::Csvable
    extend ActiveSupport::Concern
    
    module ClassMethods
      @@gtfs_cols = {}
      
      #
      # Defines a map between GtfsApi model column name and the GTFS column spcecification. 
      # Used for import and export
      #
      # @param gtfs_api_name[Symbol] name of column in the GtfsApi Model 
      # @param gtfs_feed_name[Symbol] name of the column in the GTFS feed specification. 
      #   Optional if the names follows the conventions defined.
      # 
      #
      # @example
      #   class GtfsApi::Agency < ActiveRecord::Base
      #    include GtfsApi::Concerns::Models::Concerns::Csvable
      #     set_gtfs_col :name            # expected GTFS feed file column: name 
      #     set_gtfs_col :example, :test  # expected GTFS feed file column: test
      #   end
      def set_gtfs_col (gtfs_api_name, gtfs_feed_name = nil )
        gtfs_feed_name = gtfs_api_name if gtfs_feed_name.nil?
        @@gtfs_cols[self] = {} if @@gtfs_cols[self].nil? 
        @@gtfs_cols[self][gtfs_api_name] = gtfs_feed_name 
      end
      
      # Map of GtfsApi columns and Gtfs standar columns for this class
      def gtfs_cols
        @@gtfs_cols[self]
      end
      
      def gtfs_cols_raw
        @@gtfs_cols
      end
      #
      # This method creates a new instance of the model using as input a row
      #  file in the gtfs_feed
      #
      # @example
      #  #row example
      #  csv_row = {:agency_name=>'agency name', ... }
      #
      # @param csv_row[Hash] a row of one of the file feeds
      #
      def new_from_gtfs_feed(csv_row)
        # rehash the csv_row, remove the prefix (ex: "agency_" in agency file columns)
        prefix = self.to_s.split("::").last.downcase + '_'
        
        csv_rehashed = Hash[csv_row.map {|k, v| 
          if k.to_s == "#{prefix}id"
            ['io_id'.to_sym, v]
          else #remove prefix except when the resulting string is "type"
            (k.to_s.sub(prefix,'') == 'type')? [k,v] : [k.to_s.sub(prefix,'').to_sym,v] 
          end
          }
        ]
        #puts csv_rehashed
        self.new(csv_rehashed)
      end #new_from_csv
    end #ClassMethods  
end
