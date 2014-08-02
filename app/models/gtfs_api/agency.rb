module GtfsApi
  class Agency < ActiveRecord::Base
 
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
