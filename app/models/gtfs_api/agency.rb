
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

    #def after_save
    #  if io_id = nil
    #    auto_io_id
    #    save!
    #  end


    # ASSOCIATIONS
    has_many :routes
    has_many :fare_attributes
    belongs_to :feed

    private

    #
    # sets the io_id. Use it when a io_id is not provided
    # it creates an acronym with the first letters
    # Example:
    #  ...
    #  other initializations
    #  ...
    #  agency.name = "metropolitan transports of albacete"
    #  agency.save!
    #    #=> id = 100
    #  agency.io_id
    #   #=> 100_MTOA
    #
    # TODO test
    def auto_io_id
      io_id = self.id + "_" + name.split(/\s+/).map(&:first).join.upcase
      io_id = feed.prefix + io_id if feed.prefix.present?
    end
  end
end
