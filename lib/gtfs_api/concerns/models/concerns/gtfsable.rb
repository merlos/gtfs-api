

#
# This concern helps a GtfsApi model to import and export from and to a GTFS Feed file
#
# 
# 
module GtfsApi::Concerns::Models::Concerns::Gtfsable
    extend ActiveSupport::Concern
    
    #
    # returns the columns of this model with the names of the gtfs feed
    def rehash_to_gtfs_feed 
      gtfs_feed_hash = {}
      self.gtfs_cols.each { |gtfs_api_col,gtfs_feed_col| 
        gtfs_feed_hash[gtfs_feed_col] = self[gtfs_api_col] 
      }
      
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
      # @param gtfs_api_name[Symbol] name of column in the GtfsApi Model 
      # @param gtfs_feed_name[Symbol] name of the column in the GTFS feed specification. 
      #   Optional if the names follows the conventions defined.
      # 
      #
      # @example
      #   class GtfsApi::Agency < ActiveRecord::Base
      #    include GtfsApi::Concerns::Models::Concerns::Gtfsable
      #     set_gtfs_col :name            # expected GTFS feed file column: name 
      #     set_gtfs_col :example, :test  # expected GTFS feed file column: test
      #   end
      def set_gtfs_col (gtfs_api_name, gtfs_feed_name = nil )
        gtfs_feed_name = gtfs_api_name if gtfs_feed_name.nil?
        @@gtfs_cols[self] = {} if @@gtfs_cols[self].nil? 
        @@gtfs_cols[self][gtfs_api_name] = gtfs_feed_name 
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
      def gtfs_cols_inverted
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
      def rehash_from_gtfs_feed(csv_row)
        to_gtfs_api = self.gtfs_cols_inverted
        csv_rehashed = Hash[csv_row.map {|gtfs_feed_col, v| 
          [to_gtfs_api[gtfs_feed_col],v]
          }
        ]
      end 
      
      def new_from_gtfs_feed(csv_row)
        self.new(self.rehash_from_gtfs_feed(csv_row)) 
      end 
        
    end #ClassMethods  
end
