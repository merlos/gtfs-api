$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "gtfs_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "gtfs_api"
  s.version     = GtfsApi::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of GtfsApi."
  s.description = "TODO: Description of GtfsApi."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.4"
  s.add_dependency "iso639-validator"
  s.add_dependency "gtfs-reader"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "yard"
end
