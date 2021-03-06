# Gtfs Api for Rails

This gem is a ruby on rails [engine](http://guides.rubyonrails.org/engines.html) that is able to import and export a [Google Transit Feed Specification
[(GTFS)](https://developers.google.com/transit/gtfs/reference) feed into a database. It has the ActiveRecords

## Status of the project.

* The engine is in an early version of development.
* The engine includes tools to import a GTFS feed.
* Models perform validations to comply with the GTFS specification.
* The model is tested.

* Import needs some more testing.
* Export is not already done.

## Who can use this engine.

If you plan to build a public transport mobile app or web, based on a GTFS feed, this gem may help you to forget about all the server side.

If you plan to build a GTFS feed editor this gem may help you.

If you are part of the development team of a transport agency this can
help you to populate your data and make it available for developers
to create mobile and web apps.

Note: This project is still on an early stage, so keep in mind that
if you plan to set it on a production environment.


## The [why of Fry](https://en.wikipedia.org/wiki/The_Why_of_Fry)?
The author and contributors of this software believe in open source
as a key of innovation as well as public transportation as a
democratic path to freedom and development. Please, __abstain to use
this software if you don't share this belief__.

"An advanced city is not one where even the poor use cars, but
rather one where even the rich use public transport" - Enrique Peñalosa
former Mayor of Bogotá (Colombia)
[see Ted Talk](https://www.ted.com/talks/enrique_penalosa_why_buses_represent_democracy_in_action)


## Install

Add the following line to your `Gemfile`

```
gem 'gtfs-reader', :git=>"https://github.com/merlos/gtfs-reader.git", :branch => 'master'
gem 'gtfs_api'
```

Then run

```
bundle install
```

Copy the migrations and migrate the database

```
rake gtfs:migrate
```

<!--
Edit your `routes.rb`, and add this line

```
mount GtfsApi::Engine => "/gtfs/"
```

This will add the API routes under the /gtfs/ namespace
-->

##Importing a feed

To import a feed you just need to copy the feed zipped
in `db/gtfs/feed.zip` and run this task:

```
rake gtfs:import

```
Optionally you can download the feed directly from a URL:

```
rake gtfs:import[http://www.site.com/gtfs_file.zip]
```
You can find many GTFS feeds on [GTFS data Exchange](http://www.gtfs-data-exchange.com/)


### Importing Notes
GtfsApi supports multiple feed imports. That is, you can import
several feeds into the same database. But in order to do you should
care about id clashing (feed one has route "Route1" and feed two has
route_id "Route1").

__TODO__
If you want to include more than one feed without worrying about the
name clashing, just add the column `feed_id` with a unique value in each
`feed_info.txt` file of all your feeds.

__TODO__ GtfsApi importer will add the value of the column `feed_id` as prefix on all the ids of all the files of the feed. For example, in a feed that has feed_id= "CA" and an `agency.txt` has
`agency_id="CADE"` then the stored value for agency will be `"CA_CADE"`.

Some feeds may not include `agency_id` in `agency.txt`. In those cases `agency_id`
is auto generated during import.

Also, in order to support multiple agencies, `fare_attribute.txt` should
include the `agency_id`.

##Updating a feed
__TODO__ At this moment you need to clean the database and upload the feed again.
__TODO__ Add docummentation

##Exporting a feed
__TODO__ Not implemented yet.


###Google Transit Extensions Support
Google Inc. has defined a set of fields with its partners that
[extend the GTFS Specification](https://support.google.com/transitpartners/answer/2450962?hl=en)

GtfsApi supports the following extensions:

  1. column agency_id in fare_attributes.txt (for multi-agency support)
  2. additional route types (https://support.google.com/transitpartners/answer/3520902)
  3. column vehicle_type in stops.txt
  4. set location_type = 2 in stops.txt where 2 indicates an entrance. Note that: In this case stop_id must also specify parent_station. (partially supported __TODO_Validate_parent_station___)
  5.- on fare_attributes.txt, the field transfers accepts the range 0 to 5. In GTFS Spec is defined from [0..2]

Not supported yet:
  1.- optional column field platform_code in stops.txt
  2.- translations.txt
  3.- route-to-route and trip-to-trip transfers additional values

## Sample App

- [panatrans-api](https://github.com/merlos/panatrans-api/tree/features/gtfs-to-panatrans) Simple implementation of an API for displaying transportation stops and routes of Panama. This link points to the branch in which this engine is being used (testing).
- [panatrans-web](https://github.com/merlos/panatrans-web) Web client based on AngularJS and Bootstrap that works with panatrans-api.

## Notes for developers

### Models

On model attributes names we got rid of all non informative prefixes of some tables. For example "agency_name" column in agency.txt was renamed to "name" in the Agency model.

Because rails ids are in general integers and to keep consistency among imports and exports internally string "whatever_ids" defined in the GTFS spec have been converted into "io_id" on each model and the primary key is the rails id. Also, keeping an integer id it may help on performance for large

To make it easy update and delete feeds from different feeds, all models that hold GTFS data include a relation to the model Feed. Whenever you import a feed a new feed a reference to the feed is added.

### Model map

Here you have the names of the models that hold the information of the feed as well as the properties defined.


```
GtfsApi::Feed
model					                      feed
-----					                      ----
publisher_name                <=> 	feed_publisher_name
publisher_url                 <=> 	feed_publisher_url
lang                          <=> 	feed_lang
start_date                    <=> 	feed_start_date
end_date                      <=> 	feed_end_date
version                       <=> 	feed_version
io_id                         <=> 	feed_id
name                          <=> 	name
--------------------------------------------

GtfsApi::Agency
model					                      feed
-----					                      ----
io_id                         <=> 	agency_id
name                          <=> 	agency_name
url                           <=> 	agency_url
timezone                      <=> 	agency_timezone
lang                          <=> 	agency_lang
phone                         <=> 	agency_phone
fare_url                      <=> 	agency_fare_url
--------------------------------------------

GtfsApi::Route
model					                      feed
-----					                      ----
io_id                         <=> 	route_id
short_name                    <=> 	route_short_name
long_name                     <=> 	route_long_name
desc                          <=> 	route_desc
route_type                    <=> 	route_type
url                           <=> 	route_url
color                         <=> 	route_color
text_color                    <=> 	route_text_color
agency_io_id                  <=> 	agency_id
--------------------------------------------

GtfsApi::Calendar
model					                      feed
-----					                      ----
service_io_id                 <=> 	service_id
monday                        <=> 	monday
tuesday                       <=> 	tuesday
wednesday                     <=> 	wednesday
thursday                      <=> 	thursday
friday                        <=> 	friday
saturday                      <=> 	saturday
sunday                        <=> 	sunday
start_date                    <=> 	start_date
end_date                      <=> 	end_date
--------------------------------------------

GtfsApi::CalendarDate
model					                      feed
-----					                      ----
service_io_id                 <=> 	service_id
date                          <=> 	date
exception_type                <=> 	exception_type
--------------------------------------------

GtfsApi::Shape
model					                      feed
-----					                      ----
io_id                         <=> 	shape_id
pt_lat                        <=> 	shape_pt_lat
pt_lon                        <=> 	shape_pt_lon
pt_sequence                   <=> 	shape_pt_sequence
dist_traveled                 <=> 	shape_dist_traveled
--------------------------------------------

GtfsApi::Trip
model					                      feed
-----					                      ----
route_io_id                   <=> 	route_id
service_io_id                 <=> 	service_id
io_id                         <=> 	trip_id
headsign                      <=> 	trip_headsign
short_name                    <=> 	trip_short_name
direction                     <=> 	direction_id
block_id                      <=> 	block_id
shape_id                      <=> 	shape_id
wheelchair_accesible          <=> 	wheelchair_accesible
bikes_allowed                 <=> 	bikes_allowed
--------------------------------------------

GtfsApi::Stop
model					                      feed
-----					                      ----
io_id                         <=> 	stop_id
code                          <=> 	stop_code
name                          <=> 	stop_name
desc                          <=> 	stop_desc
lat                           <=> 	stop_lat
lon                           <=> 	stop_lon
zone_id                       <=> 	zone_id
url                           <=> 	stop_url
location_type                 <=> 	location_type
parent_station_id             <=> 	parent_station
timezone                      <=> 	stop_timezone
wheelchair_boarding           <=> 	wheelchair_boarding
vehicle_type                  <=> 	vehicle_type
--------------------------------------------

GtfsApi::StopTime
model					                      feed
-----					                      ----
trip_io_id                    <=> 	trip_id
arrival_time                  <=> 	arrival_time
departure_time                <=> 	departure_time
stop_io_id                    <=> 	stop_id
stop_sequence                 <=> 	stop_sequence
stop_headsign                 <=> 	stop_headsign
pickup_type                   <=> 	pickup_type
drop_off_type                 <=> 	drop_off_type
dist_traveled                 <=> 	shape_dist_traveled
--------------------------------------------

GtfsApi::Frequency
model					                      feed
-----					                      ----
trip_io_id                    <=> 	trip_id
start_time                    <=> 	start_time
end_time                      <=> 	end_time
headway_secs                  <=> 	headway_secs
exact_times                   <=> 	exact_times
--------------------------------------------

GtfsApi::FareAttribute
model					                      feed
-----					                      ----
io_id                         <=> 	fare_id
agency_io_id                  <=> 	agency_id
price                         <=> 	price
currency_type                 <=> 	currency_type
payment_method                <=> 	payment_method
transfers                     <=> 	transfers
transfer_duration             <=> 	transfer_duration
--------------------------------------------

GtfsApi::Transfer
model					                      feed
-----					                      ----
from_stop_io_id               <=> 	from_stop_id
to_stop_io_id                 <=> 	to_stop_id
transfer_type                 <=> 	transfer_type
min_transfer_time             <=> 	min_transfer_time
--------------------------------------------

GtfsApi::FareRule
model					                      feed
-----					                      ----
fare_io_id                    <=> 	fare_id
route_io_id                   <=> 	route_id
origin_id                     <=> 	origin_id
destination_id                <=> 	destination_id
contains_id                   <=> 	contains_id
--------------------------------------------


Files linked to models
-----------------------------------
GtfsApi::FeedInfo                       <=> 	feed_info
GtfsApi::Agency                         <=> 	agency
GtfsApi::Route                          <=> 	routes
GtfsApi::Calendar                       <=> 	calendar
GtfsApi::CalendarDate                   <=> 	calendar_dates
GtfsApi::Shape                          <=> 	shapes
GtfsApi::Trip                           <=> 	trips
GtfsApi::Stop                           <=> 	stops
GtfsApi::StopTime                       <=> 	stop_times
GtfsApi::Frequency                      <=> 	frequencies
GtfsApi::FareAttribute                  <=> 	fare_attributes
GtfsApi::Transfer                       <=> 	transfers
GtfsApi::FareRule                       <=> 	fare_rules
```

### I18n in models

Internationalization strings are located in `config/locales/xx.yml`. Currently, only English strings are provided.

```
# Example of i18m paths for errors in English.
en:
  activerecord:
    errors:
      models:
        gtfs_api/route:
          attributes:
            short_name:
              short_and_long_name_blank: "and long name both cannot be blank"
```

## Testing
GtfsApi relies heavily in tests. It uses the standard test suite that comes with rails. To run the tests:

```
rake test
```

If you see many useless warnings run:

```
RUBYOPT=-W0 rake test
```

### Testing Import/Export
__TODO__

There is a set of fake feeds to run some tests. These feeds are available on the folder `/test/fixtures/feed/`

 * `feed_panama/`: Basic feed with two agencies (metro,mibus), each agency has a route (linea1, alb-mar) and each route has two trips (linea1-i,linea1-r | alb-mar-i, alb-mar-r).

 * `full_feed/`: A feed with all the files.


## Generating the API documentation

Some parts of the code are documented with [yardoc](http://yardoc.org/). To generate the HTML, run the following comand:

```
yard doc
```

This generates some html documents in the `doc/` folder.

## Author & contributors

(C) Juan Manuel Merlos http://www.merlos.org | [@merlos](http://twitter.com/merlos)

Want to contribute? Fork the project and make pull a request :)

## License
This project rocks and uses MIT-LICENSE.

##Acknowledgements

Thanks to Sangster for creating the gem [gtfs-reader](https://github.com/sangster/gtfs-reader/)

## Related Projects

  - [panatrans-api](https://github.com/merlos/panatrans-api) Simple implementation of an API for displaying transportation stops and routes
  - [panatrans-web](https://github.com/merlos/panatrans-web) Web client based on AngularJS and Bootstrap that works with panatrans-api
  - [panatrans-dataset](https://github.com/merlos/panatrans-dataset) Dataset that works with panatans-api. This dataset includes a collaborative database of the Panamenian bus system information.

Other projects:

  - [Transit Feeds](http://transitfeeds.com/) A public repository of GTFS feeds
  - [Transit land ](https://transit.land/) Another public repository of GTFS feeds and API
  - [gtfs_engine](https://github.com/sangster/gtfs_engine) another engine for rails.
  - [Open Trip Planner](http://www.opentripplanner.org/)
