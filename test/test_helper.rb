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


# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }


ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)

if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end


# - - - - - - - - - - - - - - - - - - - - - -
# These methods are common for several model
# COMMON METHODS FOR MODEL TESTS
# - - - - - - - - - - - - - - - - - - - - -
#

# tests that a model_class can be imported from the row
#
# model_class needs to include the gtfsable Concern
#test_class has to define fill_valid_model(feed = nil)
#
# @param model_class [Class] model class to be tested
# @param test_class [Class] test class of the model
# @param exceptions [Array] Array of symbols of model_attr that cannot be tested (ie: dates, times)
#
def generic_row_import_test(model_class, test_class, exceptions)
  feed_row = test_class.valid_gtfs_feed_row
  feed = GtfsApi::FeedTest.fill_valid_model
  feed.save!
  model = model_class.new_from_gtfs(feed_row, feed)
  assert model.valid?, model.errors.to_a.to_s
  model_class.gtfs_cols.each do |model_attr, feed_col|
    next if exceptions.include? (model_attr)
    feed_value = feed_row[feed_col]
    feed_value = feed_value.to_f if model.send(model_attr).is_a? Numeric
    feed_value = Time.new_from_gtfs(feed_value) if model.send(model_attr).is_a? Time
    assert_equal model.send(model_attr), feed_value, "Testing " + model_attr.to_s + " vs " + feed_col.to_s
  end

end

# tests that a model_class can be imported.
#
# model_class needs to include the gtfsable Concern
# test_class has to define valid_gtfs_feed_row_for_feed(feed)
#
# @param model_class [Class] model class to be tested
# @param test_class [Class] test class of the model

def generic_row_import_test_for_feed_with_prefix(model_class, test_class)
  feed = GtfsApi::FeedTest.fill_valid_model 'feed_prefix'
  feed.save!
  # valid_gtfs_feed_row_for_feed shall return a row of the gtfs feed that
  # is valid for the feed (a GtffsApi:Feed instance).
  feed_row = test_class.valid_gtfs_feed_row_for_feed feed
  # model_class shall include Gtfsable concern
  model = model_class.new_from_gtfs(feed_row, feed)
  assert model.valid?, model.errors.to_a.to_s
  # validate that the feed.prefix was added to each column as defined in the model
  # Columns that shall include the prefix are set in model calling the method set_gtfs_cols_with_prefix.
  #puts "---- feed row" if model_class == GtfsApi::Stop
  #puts feed_row if model_class == GtfsApi::Stop
  #puts "----- model" if model_class == GtfsApi::Stop
  #puts model.inspect if model_class == GtfsApi::Stop
  #puts model_class.gtfs_cols_with_prefix if model_class == GtfsApi::Stop
  model_class.gtfs_cols_with_prefix.each do |feed_col|
    model_attr = model_class.attr_for_gtfs_col(feed_col)
    assert_equal model.send(model_attr), feed.prefix + feed_row[feed_col], "Testing " + model_attr.to_s + " vs " + feed_col.to_s
  end
end

#
# @see generic_row_import_test
#
def generic_model_export_test(model_class, test_class, exceptions)
  model = test_class.fill_valid_model
  feed_row = model.to_gtfs
  #puts feed_row
  model_class.gtfs_cols.each do |model_attr, feed_col|
    next if exceptions.include? (model_attr)
    feed_value = feed_row[feed_col]
    feed_value = feed_value.to_f if model.send(model_attr).is_a? Numeric
    feed_value = Time.new_from_gtfs(feed_value) if model.send(model_attr).is_a? Time
    assert_equal model.send(model_attr), feed_value, "Testing " + model_attr.to_s + " vs " + feed_col.to_s
  end
end
