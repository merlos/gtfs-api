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


## The why of Fry?
The author and contributors of this software believe in open source
as a key of innovation as well as public transportation as a
democratic path to freedom and development. Please, __abstain to use
this software if you don't share this belief__.

"An advanced city is not one where even the poor use cars, but
rather one where even the rich use public transport" - Enrique Peñalosa
former Mayor of Bogotá
[see Ted Talk](https://www.ted.com/talks/enrique_penalosa_why_buses_represent_democracy_in_action)


## Install

Add the following line to your `Gemfile`

```
gem gtfs_api
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

__TODO__ __TO_TEST___
If you want to include more than one feed without worrying about the
name clashing, just add the column `feed_id` with a unique value in each
`feed_info.txt` file of all your feeds.

GtfsApi importer will add the value of the column `feed_id` as prefix on all the ids of all the files of the feed. For example, in a feed that has feed_id= "CA" and an `agency.txt` has
`agency_id="CADE"` then the stored value for agency will be `"CA_CADE"`.

__TODO__ __TO_TEST___
Some feeds may not include the `agency_id`. In those cases `agency_id`
is auto generated during import.

Also, in order to support multiple agencies, `fare_attribute.txt` should
include the `agency_id`

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

## Sample Client
__TODO__
To test the API, you have available a simple javascript client that is ready to consume GtfsApi.

## Notes for developers

### Models

On model attributes names we got rid of all non informative prefixes of some tables. For example "agency_name" column in agency.txt was renamed to "name" in the Agency model.

Because rails ids are in general integers and to keep consistency among imports and exports internally string "whatever_ids" defined in the GTFS spec have been converted into "io_id" on each model and the primary key is the rails id. Also, keeping an integer id it may help on performance for large

To make it easy update and delete feeds from different feeds, all models that hold GTFS data include a relation to the model Feed. Whenever you import a feed a new feed

## Testing
GtfsApi is relies heavily in tests. It uses the standard test suite that comes with rails. To run the tests:

```
rake test
```

if you see many useless warnings run:

```
RUBYOPT=-W0 rake test
```

### Testing Import/Export
__TODO__

There is a set of fake feeds to run some tests on the folder /test/fixtures/feed_***

 * feed_panama/: Basic feed with two agencies (metro,mibus), each agency has a route (linea1, alb-mar) and each route has two trips (linea1-i,linea1-r | alb-mar-i, alb-mar-r).

 * full_feed/: A feed with all the files.


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
     - [gtfs_engine](https://github.com/sangster/gtfs_engine) another engine for rails.
     - [Open Trip Planner](http://www.opentripplanner.org/)
