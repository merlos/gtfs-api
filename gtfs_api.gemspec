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
  s.description = "Rails engine that populates a RESTFUL JSON API of a GTFS feed"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.4"
  s.add_dependency "iso639-validator", '~> 0.0.2'
  s.add_dependency "iso4217-validator", '~> 0.0.2'
  #s.add_dependency "gtfs-reader"
  
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "yard"
end
