$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "gtfs_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "gtfs_api"
  s.version     = GtfsApi::VERSION
  s.authors     = ["merlos"]
  s.email       = ["jmmerlos@merlos.org"]
  s.homepage    = "http://github.com/merlos/gtfs-api"
  s.summary     = "Rails Engine to make GTFS easier"
  s.description = "Rails engine that handles the import and export of a GTFS feed to a model"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails', '~> 4.2.2'
  s.add_dependency 'iso639-validator', '~> 0.0.2'
  s.add_dependency 'iso4217-validator', '~> 0.0.2'
  s.add_dependency 'jbuilder', '>=2.1.3'
  s.add_dependency 'haversine', '~> 0.3.0' # calculate distance
  s.add_dependency 'ruby_kml', '~> 0.1.7' # to export stops as kml
  s.add_dependency 'andrewhao-gpx', '~> 0.8'

  #s.add_dependency "gtfs-reader" #<--- TODO make a merlos-gtfs-reader or something

  # Development dependencies
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "yard" # for docummentation
end
