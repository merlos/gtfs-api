require 'gtfs_api/io/importer'
require 'gtfs_api/io/exporter'

namespace :gtfs do
  desc 'Copy migrations from gtfs_api to application and perform the migration (db:migrate)'
  task :migrate => :environment do |t, args|
    # this task is a shortcut of
    copy_migrations = 'gtfs_api:install:migrations'
    migrate = 'db:migrate'
    #app prefix is required if called from engine during development
    copy_migrations.prepend('app:') if t.to_s.split(':').include? ('app')
    migrate.prepend('app:') if t.to_s.split(':').include? ('app')
    Rake::Task[copy_migrations].invoke  
    Rake::Task[migrate].invoke
  end
  
  #
  # IMPORT 
  #
  desc "import zip feed file/url into gtfs_api database. default zip_file db/gtfs/feed.zip. Default prefix: none. Use prefix = auto to autogenerate random string "
  task :import, [:zip_file, :prefix] => :environment do |t, args|
    args.with_defaults(
      zip_file: Rails.root.join('db','gtfs','feed.zip').to_s, 
      prefix: ""
    )
    if args[:prefix] == 'auto' 
      args[:prefix] = (0...8).map { (65 + rand(26)).chr }.join
    end
    puts "Importing with params: #{args}"
    GtfsApi::Io::Importer.import args[:zip_file], prefix: args[:prefix], verbose: true
    
  end
  
  #
  # EXPORT 
  #
  desc "export zip feed from gtfs_api database. default zip_file db/gtfs/export.zip default prefix none"
  task :export, [:zip_file, :prefix] => :environment do |t, args|
    args.with_defaults(
      zip_file: Rails.root.join('db','gtfs','export.zip').to_s, 
      prefix: ""
    )
    if args[:prefix] == 'auto' 
        args[:prefix] = (0...8).map { (65 + rand(26)).chr }.join
    end
    puts "Exporting with params: #{args}"
  end
  
end

    