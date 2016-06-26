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


require 'test_helper'

module GtfsApi
  class FareAttributeTest < ActiveSupport::TestCase

    # Creates a valid model
    # @param feed [GtfsApi:Feed] a feed existent on the database
    def self.fill_valid_model (feed = nil)
      if feed.nil? then
        feed = FeedTest.fill_valid_model
        feed.save!
      end

      unique = Time.now.to_f.to_s
      a = AgencyTest.fill_valid_model feed
      a.save!


      return FareAttribute.new(
        io_id: 'fare_attribute_' + unique,
        agency: a,
        price: 11.11,
        currency_type: 'EUR',
        payment_method: FareAttribute::ON_BOARD,
        transfers: FareAttribute::TWICE,
        transfer_duration: 10,
        feed: feed)
    end

    def self.valid_gtfs_feed_row
      {
        fare_id: Time.now.to_f.to_s,
        price: 11.11,
        currency_type: 'EUR',
        payment_method: FareAttribute::ON_BOARD,
        transfers: FareAttribute::TWICE,
        transfer_duration: 10
      }
    end

    def self.valid_gtfs_feed_row_for_feed(feed)
      a = AgencyTest.fill_valid_model feed
      a.save!
      row = self.valid_gtfs_feed_row
      agency_id = feed.prefix.present? ? a.io_id.gsub(feed.prefix,'') : a.io_id
      row[:agency_id] = agency_id
      return row
    end

    def setup
      @model = FareAttributeTest.fill_valid_model
    end

    #
    # VALIDATIONS
    #

    test "valid fare_attribute" do
      assert @model.valid?, @model.errors.full_messages
    end

    test "fare_attribute io_id presence required" do
      @model.io_id = nil
      assert @model.invalid?, '_fare_id not present but fare_attributes valid'
    end

    test "price presence required" do
      @model.price = nil
      assert @model.invalid?, 'price presence not required?'
    end

    test "currency_type presence required" do
      @model.currency_type = nil
      assert @model.invalid?
    end


    test "currency_type length cannot greater than 3" do
      @model.currency_type = "EURO"
      assert @model.invalid?
    end

    test "currency_type length cannot be less than 3" do
      @model.currency_type = "EU"
      assert @model.invalid?
    end

    test "currency_type is a valid ISO4217 uppercase code " do
      @model.currency_type = 'eur'
      assert @model.invalid?
    end


    test "currency_type is a valid ISO4217 code" do
      @model.currency_type = 'ZZZ'
      assert @model.invalid?
    end

    test "payment_method presence" do
      @model.payment_method = nil
      assert @model.invalid?
    end

    test "payment_method has to be positive" do
      @model.payment_method = -1
      assert @model.invalid?
    end

    test "payment_method can be 0 or 1" do
      @model.payment_method = 0
      assert @model.valid?
      @model.payment_method= 1
      assert @model.valid?
    end

    test "payment_method cannot be larger than 1" do
      @model.payment_method = 2
      assert @model.invalid?
    end

    test 'transfer has to be integer' do
      @model.transfers = 1.2
      assert @model.invalid?
    end

    test 'transfer cannot be negative' do
      @model.transfers = -1
      assert @model.invalid?
    end

    test 'transfers is optional' do
      @model.transfers = nil
      assert @model.valid?
    end

    test "transfers range from 0 to 5 are valid" do
      @model.transfers = 0
      assert @model.valid?
      @model.transfers = 1
      assert @model.valid?
      @model.transfers = 2
      assert @model.valid?
      @model.transfers = 3
      assert @model.valid?
      @model.transfers = 4
      assert @model.valid?
      @model.transfers = 5
      assert @model.valid?
    end

    test "transfer_range greater than 5 is invalid" do
      @model.transfers = 6
      assert @model.invalid?
    end

   test "uniqueness of fare_id" do
     f = FareAttributeTest.fill_valid_model
     f.save!
     f2 = FareAttributeTest.fill_valid_model
     f2.io_id = f.io_id
     assert f2.invalid?
     assert_raises ( ActiveRecord::RecordInvalid) {f2.save!}
     f3 = FareAttributeTest.fill_valid_model
     f3.io_id="newValidId"
     assert_nothing_raised(ActiveRecord::RecordInvalid) {f3.save!}
   end

   #
   # ASSOCIATIONS
   #

   test "fare_attribute has_many fare_rules" do
     f = FareAttributeTest.fill_valid_model
     f.save!
     fr1 = FareRuleTest.fill_valid_model
     fr1.fare = f
     fr1.save!
     fr2 = FareRuleTest.fill_valid_model
     fr2.fare = f
     fr2.save!
     assert_equal 2, f.fare_rules.count
   end

   #
   # GTFSABLE IMPORT/EXPORT
   #

   test "fare_attribute row can be imported into a FareAttribute model" do
     model_class = FareAttribute
     test_class = FareAttributeTest
     exceptions = [] #exceptions, in test
     #--- common part
     feed_row = test_class.valid_gtfs_feed_row
     feed = FeedTest.fill_valid_model
     feed.save!
     model = model_class.new_from_gtfs(feed_row,feed)
     assert model.valid?
     model_class.gtfs_cols.each do |model_attr, feed_col|
       next if exceptions.include? (model_attr)
       assert_equal model.send(model_attr), feed_row[feed_col], "Testing " + model_attr.to_s + " vs " + feed_col.to_s
     end
     #------
   end

   test "fare_attribute row can be imported into a FareAttribute model with a feed with prefix" do
     model_class = FareAttribute
     test_class = FareAttributeTest
     generic_row_import_test_for_feed_with_prefix(model_class, test_class) # defined in test_helper
   end

   test "a FareAttribute model can be exported into a gtfs row" do
     model_class = FareAttribute
     test_class = FareAttributeTest
     exceptions = []
     #------ Common_part
     model = test_class.fill_valid_model
     feed_row = model.to_gtfs
     model_class.gtfs_cols.each do |model_attr, feed_col|
       next if exceptions.include? (model_attr)
       assert_equal model.send(model_attr), feed_row[feed_col], "Testing " + model_attr.to_s + " vs " + feed_col.to_s
     end
   end

  end #class
end #module
