require 'test_helper'

module GtfsApi
  class ServiceTest < ActiveSupport::TestCase

    def self.fill_valid_model
      feed = FeedTest.fill_valid_model
      feed.save!
      return Service.new( {
        io_id: "service_" + Time.new.to_f.to_s,
        feed: feed
      })
    end

    def setup
      @model = ServiceTest.fill_valid_model
    end

    test "io_id is required" do
      @model.io_id = nil
      assert @model.invalid?
    end

    test "io_id is unique" do
      @model.io_id = "service"
      @model.save!
      model2 = ServiceTest.fill_valid_model
      model2.io_id = "service"
      assert model2.invalid?
    end


    # ASSOCIATIONS
    test "has many calendars association" do

    end

    test "has many calendars dates association" do
    end

    test "has many trips association" do
    end


  end
end
