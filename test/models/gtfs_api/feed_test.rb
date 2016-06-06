require 'test_helper'

module GtfsApi
  class FeedTest < ActiveSupport::TestCase

    def self.fill_valid_model (prefix = nil)
      Feed.new( {
        io_id: "feed_io" + Time.new.to_f.to_s,
        name: "feed name " + Time.new.to_f.to_s,
        source_url: "http://gihub.com/merlos/gtfs_api",
        prefix: prefix
        })
    end




    def setup
      @model = FeedTest.fill_valid_model
    end

    test "valid model" do
      assert @model.valid?
    end

    test "io_id is required" do
      @model.io_id = nil
      assert @model.invalid?
    end

    test "https is a valid source_url" do
      @model.source_url = "https://www.github.com/merlos/gtfs_api"
      assert @model.valid?
    end

    test "another valid format" do
      @model.source_url = "ftp://www.google.es"
      assert @model.valid?
    end

    test "io_id uniqueness is required" do
      @model.io_id = "feed_io_id"
      @model.save!
      model2 = FeedTest.fill_valid_model
      model2.io_id = "feed_io_id"
      assert model2.invalid?
    end

    test "prefix uniqueness is required" do
      @model.prefix = 'prefix'
      @model.save!
      model2 = FeedTest.fill_valid_model 'prefix'
      #assert model2.valid?
      assert model2.invalid?
    end

    # method for testing GTFSApi::Feed has_many associations
    #
    # example: validate_association "CalendarDate"
    #
    def validate_association(associated_model_class_name)
      association_name = associated_model_class_name.underscore.pluralize
      # => "calendar_dates"
      associated_model_test_class = Object.const_get("GtfsApi::" + associated_model_class_name + "Test")
      # => GtfsApi::CalendarDateTest
      @model.save!
      assert_equal 0, @model.send(association_name).count
      #the associated_model_test_class shall have a method called filL_valid_model
      # that retuns a CalendarDate model object that is valid (ie: passes validations)
      associated_object = associated_model_test_class.fill_valid_model
      #and the model attribute called feed that holds the belongs_to feed association
      associated_object.feed = @model
      associated_object.save
      assert_equal 1, @model.send(association_name).count
    end

    # ASSOCIATIONS
    test "agency is associated to feed" do
      validate_association("Agency")
    end

    test "CalendarDate is associated to feed" do
      validate_association("CalendarDate")
    end

    test "Calendar is associated to feed" do
      validate_association("Calendar")
    end

    test "FareAttribute is associated to feed" do
      validate_association("FareAttribute")
    end

    test "FareRule is associated to feed" do
      validate_association("FareRule")
    end

    test "FeedInfo is associated to feed" do
      validate_association("FeedInfo")
    end

    test "Frequency is associated to feed" do
      validate_association("Frequency")
    end

    test "Route is associated to feed" do
      validate_association("Route")
    end

    test "Shape is associated to feed" do
      validate_association("Shape")
    end

    test "Stop is associated to feed" do
      validate_association("Stop")
    end

    test "StopTime is associated to feed" do
      validate_association("StopTime")
    end

    test "Transfer is associated to feed" do
      validate_association("Transfer")
    end

    test "Trip is associated to feed" do
      validate_association("Trip")
    end

    test "Service is associated to feed" do
      validate_association("Service")
    end

  end
end
