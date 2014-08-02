# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140713165440) do

  create_table "gtfs_api_agencies", force: true do |t|
    t.string   "io_id"
    t.string   "name"
    t.string   "url"
    t.string   "timezone"
    t.string   "lang"
    t.string   "phone"
    t.string   "fare_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gtfs_api_agencies", ["io_id"], name: "index_gtfs_api_agencies_on_io_id"

  create_table "gtfs_api_calendar_dates", force: true do |t|
    t.integer  "service_id"
    t.string   "io_service_id"
    t.date     "date"
    t.integer  "exception_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gtfs_api_calendars", force: true do |t|
    t.string   "io_id"
    t.integer  "monday"
    t.integer  "tuesday"
    t.integer  "wednesday"
    t.integer  "thursday"
    t.integer  "friday"
    t.integer  "saturday"
    t.integer  "sunday"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gtfs_api_fare_attributes", force: true do |t|
    t.string   "io_id"
    t.decimal  "price"
    t.string   "currency_type"
    t.integer  "payment_method"
    t.integer  "transfers"
    t.integer  "transfer_duration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gtfs_api_fare_rules", id: false, force: true do |t|
    t.integer  "fare_id"
    t.string   "io_fare_id"
    t.integer  "route_id"
    t.string   "io_route_id"
    t.string   "origin_id"
    t.string   "destination_id"
    t.string   "contains_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gtfs_api_fare_rules", ["fare_id"], name: "index_gtfs_api_fare_rules_on_fare_id"

  create_table "gtfs_api_feed_infos", force: true do |t|
    t.string   "feed_publisher_name"
    t.string   "feed_publisher_url"
    t.string   "feed_lang"
    t.date     "feed_start_date"
    t.date     "feed_end_date"
    t.string   "feed_version"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gtfs_api_frequencies", force: true do |t|
    t.integer  "trip_id"
    t.time     "start_time"
    t.time     "end_time"
    t.integer  "headway_secs"
    t.integer  "exact_times"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gtfs_api_routes", force: true do |t|
    t.string   "io_id"
    t.string   "io_agency_id"
    t.integer  "agency_id"
    t.string   "short_name"
    t.string   "long_name"
    t.string   "desc"
    t.integer  "route_type"
    t.string   "url"
    t.string   "color"
    t.string   "text_color"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gtfs_api_routes", ["io_id"], name: "index_gtfs_api_routes_on_io_id"

  create_table "gtfs_api_shapes", id: false, force: true do |t|
    t.integer  "id"
    t.string   "io_id"
    t.decimal  "pt_lat",        precision: 10, scale: 6
    t.decimal  "pt_lon",        precision: 10, scale: 6
    t.integer  "pt_sequence"
    t.decimal  "dist_traveled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gtfs_api_stop_times", force: true do |t|
    t.integer  "trip_id"
    t.time     "arrival_time"
    t.time     "departure_time"
    t.integer  "stop_id"
    t.integer  "stop_sequence"
    t.string   "stop_headsign"
    t.integer  "pickup_type"
    t.integer  "drop_off_type"
    t.decimal  "shape_dist_traveled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gtfs_api_stops", force: true do |t|
    t.string   "io_id"
    t.string   "code"
    t.string   "name"
    t.string   "desc"
    t.decimal  "lat",                 precision: 10, scale: 6
    t.decimal  "lon",                 precision: 10, scale: 6
    t.string   "zone_id"
    t.string   "url"
    t.integer  "location_type"
    t.string   "io_parent_station"
    t.integer  "parent_station_id"
    t.string   "timezone"
    t.integer  "wheelchair_boarding"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gtfs_api_stops", ["io_id"], name: "index_gtfs_api_stops_on_io_id"
  add_index "gtfs_api_stops", ["zone_id"], name: "index_gtfs_api_stops_on_zone_id"

  create_table "gtfs_api_transfers", force: true do |t|
    t.string   "io_from_stop_id"
    t.string   "io_to_stop_id"
    t.integer  "from_stop_id"
    t.integer  "to_stop_id"
    t.integer  "transfer_type"
    t.integer  "min_transfer_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gtfs_api_transfers", ["from_stop_id"], name: "index_gtfs_api_transfers_on_from_stop_id"
  add_index "gtfs_api_transfers", ["to_stop_id"], name: "index_gtfs_api_transfers_on_to_stop_id"

  create_table "gtfs_api_trips", force: true do |t|
    t.string   "io_id"
    t.integer  "route_id"
    t.string   "io_route_id"
    t.integer  "service_id"
    t.string   "io_service_id"
    t.string   "headsign"
    t.string   "short_name"
    t.integer  "direction_id"
    t.string   "block_id"
    t.string   "io_shape_id"
    t.integer  "shape_id"
    t.integer  "wheelchair_accesible"
    t.integer  "bikes_allowed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gtfs_api_trips", ["block_id"], name: "index_gtfs_api_trips_on_block_id"
  add_index "gtfs_api_trips", ["io_id"], name: "index_gtfs_api_trips_on_io_id", unique: true
  add_index "gtfs_api_trips", ["shape_id"], name: "index_gtfs_api_trips_on_shape_id"

end
