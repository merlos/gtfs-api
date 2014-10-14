require 'jbuilder'

require "gtfs_api/engine"

require "gtfs_api/io/time"
require "gtfs_api/io/date"
require "gtfs_api/io/models/concerns/gtfsable"

require 'iso639/validator'   
require 'iso4217/validator'

module GtfsApi
    
  UNIQUE_IO_ID = "{**GTFSAPI_UNIQUE_IO_ID**}"
    
end
