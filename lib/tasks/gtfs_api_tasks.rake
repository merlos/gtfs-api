# The MIT License (MIT)
#
# Copyright (c) 2016 Juan M. Merlos, panatrans.org
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


require 'gtfs_api/io/importer'
require 'gtfs_api/io/exporter'

namespace :gtfs do

  #
  # MIGRATE
  #
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
  desc "import zip feed file/url into gtfs_api database. default zip_file db/gtfs/feed.zip. Default prefix: none. Use prefix = auto to autogenerate random string"
  task :import, [:zip_file, :prefix] => :environment do |t, args|
    args.with_defaults(
      zip_file: Rails.root.join('db','gtfs','feed.zip').to_s,
      prefix: nil
    )
    if args[:prefix] == 'auto'
      args[:prefix] = (0...8).map { (65 + rand(26)).chr }.join
    end
    puts "Importing with params: #{args}"
    GtfsApi::Io::Importer.import args[:zip_file], prefix: args[:prefix], verbose: true

  end


  #
  # MAPPING
  #
  desc "Displays the map between models and file columns, as well as models and feed files"
  task :model_map => :environment do |t, args|
    # Force load of the models, if not they are not show, as gtfsable methods are calle
    # after loading the files.
    # TODO how to do this more elegantly?
    GtfsableModels = [
      GtfsApi::FeedInfo,
      GtfsApi::Agency,
      GtfsApi::Route,
      GtfsApi::Calendar,
      GtfsApi::CalendarDate,
      GtfsApi::Shape,
      GtfsApi::Trip,
      GtfsApi::Stop,
      GtfsApi::StopTime,
      GtfsApi::Frequency,
      GtfsApi::FareAttribute,
      GtfsApi::Transfer,
      GtfsApi::FareRule
    ]

    GtfsApi::Agency.gtfs_cols_raw.each do |cols_map|
      puts
      puts "\t#{cols_map[0]}"
      puts "\tmodel\t\t\t\t\tfeed"
      puts "\t-----\t\t\t\t\t----"
      cols_map[1].each do |hola|
        puts "\t#{hola[0]}" + "<=> \t#{hola[1]}".indent(30 - hola[0].length)
      end
      puts "\t--------------------------------------------"
    end
    puts "\n\n\tFiles linked to models"
    puts "\t-----------------------------------"
    GtfsableModels.each do |model|
       puts "\t#{model.to_s}" + "<=> \t#{model.gtfs_file}".indent(40 - model.to_s.length)
     end
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


  #
  # list feeds
  #
  desc "list feeds currently loaded in the gtfs_api database."
  task :list => :environment do |t, args|
    GtfsApi::Feed.all.each do |feed|
      puts "\tid\tprefix\tio_id"
      puts "\t---------------------------------------------------"
      puts "\t#{feed.id}\t#{feed.prefix}\t#{feed.id}"
      puts "\tagencies: "
      feed.agencies.each do |agency|
        puts "\t\t(#{agency.io_id})#{agency.name}"
      end
    end
  end

  #
  # deletes a feed
  desc "delete feed by id. Run rake gtfs:list to get the feed id"
  task :delete, [:id] => :environment do |t, args|
  end

end
