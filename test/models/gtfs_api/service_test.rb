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
