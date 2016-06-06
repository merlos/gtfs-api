
module GtfsApi
  class Agency < ActiveRecord::Base
    include Iso639::Validator
    include GtfsApi::Io::Models::Concerns::Gtfsable
    set_gtfs_file :agency
    set_gtfs_col :io_id, :agency_id
    set_gtfs_col :name, :agency_name
    set_gtfs_col :url, :agency_url
    set_gtfs_col :timezone, :agency_timezone
    set_gtfs_col :lang, :agency_lang
    set_gtfs_col :phone, :agency_phone
    set_gtfs_col :fare_url, :agency_fare_url


    # VALIDATIONS
    validates :io_id,     allow_nil:true, uniqueness: true
    validates :name,      presence: true
    validates :url,       presence: true, :'gtfs_api/validators/url' => true
    validates :timezone,  presence: true
    validates :lang,      allow_nil: true, iso639Code: true, length: { is: 2 }
    validates :fare_url,  allow_nil: true, :'gtfs_api/validators/url'=> true
    validates :feed,      presence: true
    # TODO validate timezone

    before_save :auto_io_id

    # ASSOCIATIONS
    has_many :routes
    has_many :fare_attributes
    belongs_to :feed

    private

    def auto_io_id
      if io_id == nil then
        self.io_id = name.split(/\s+/).map(&:first).join.upcase + "_" + Time.new.to_f.to_s  
        #puts self.io_id
      end
    end

  end
end
