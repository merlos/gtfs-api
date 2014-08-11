module GtfsApi
  class Agency < ActiveRecord::Base
 
    include GtfsApi::Concerns::Models::Concerns::Csvable
    set_gtfs_col :io_id, :agency_id
    set_gtfs_col :name, :agency_name
    set_gtfs_col :url, :agency_url
    set_gtfs_col :timezone, :agency_timezone
    set_gtfs_col :lang, :agency_lang
    set_gtfs_col :phone, :agency_phone
    set_gtfs_col :fare_url, :agency_fare_url
    
    include Iso639::Validator

    validates :io_id, uniqueness: true, allow_nil:true
    validates :name, presence: true
    validates :url, presence: true 
    validates :timezone, presence: true
    validates :lang, iso639Code: true, length: { is: 2 },  allow_nil: true
  
    # TODO validate timezone
    # TODO validate urls  
  
    #associations
    has_many :routes
   
  end
end
