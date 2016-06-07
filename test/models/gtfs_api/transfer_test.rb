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
  class TransferTest < ActiveSupport::TestCase

    def self.fill_valid_model (feed = nil)
      from = StopTest.fill_valid_model feed
      to = StopTest.fill_valid_model feed
      from.save!
      to.save!
      if feed.nil?
        feed = FeedTest.fill_valid_model
        feed.save!
      end
      return Transfer.new(
        from_stop:from,
        to_stop:to,
        transfer_type: Transfer::MIN_TRANSFER_TIME_REQUIRED,
        min_transfer_time: 3600,
        feed: feed)
    end

    def self.valid_gtfs_feed_row (feed = nil)
      from = StopTest.fill_valid_model feed
      to = StopTest.fill_valid_model feed
      from.save!
      to.save!
      {
        from_stop_id: from.io_id,
        to_stop_id: to.io_id,
        transfer_type: "0",
        min_transfer_time: "3600"
      }
    end

    def setup
      @model = TransferTest.fill_valid_model
    end

     test "valid transfer" do
       assert @model.valid?, @model.errors.to_a
     end

     test "required presence of from_stop" do
       @model.from_stop = nil
       assert @model.invalid?
     end

     test "required presence of to_stop " do
       @model.to_stop = nil
       assert @model.invalid?
     end

     test "valid transfer_type range" do
       # valid range is integer 0->3
       @model.transfer_type = 0
       assert @model.valid?, @model.errors.to_a

       @model.transfer_type = 3
       assert @model.valid?, @model.errors.to_a
     end

     test 'invalid transfer_type range' do

       assert @model.valid?
       @model.transfer_type = -100
       assert @model.invalid?

       t1 = TransferTest.fill_valid_model
       t1.transfer_type = 4
       assert t1.invalid?

       t2 = TransferTest.fill_valid_model
       t2.transfer_type = 1.1
       assert t2.invalid?

       t3 = TransferTest.fill_valid_model
       t3.transfer_type = nil
       assert t3.invalid?
     end

     test 'min_transfer_time is optional' do
      @model.min_transfer_time = nil
      assert @model.valid?
     end

     test 'min_transfer_time has to be a number' do
       @model.min_transfer_time = "hola"
       assert @model.invalid?
     end

     test 'min_transfer_time has to be greater than 0' do
       @model.min_transfer_time = -1
       assert @model.invalid?
     end

     test 'min_transfer_time has to be greater an integer' do
       @model.min_transfer_time = 1.1
       assert @model.invalid?
     end

     test 'from_stop_io_id cannot set nil' do
       @model.from_stop_io_id = nil
       assert @model.invalid?
     end

     test 'to_stop_io_id cannot set nil' do
       @model.to_stop_io_id = nil
       assert @model.invalid?
     end

     test 'from_stop_io_id gets and sets from_stop' do
       assert @model.from_stop.present?
       assert_equal @model.from_stop.io_id, @model.from_stop_io_id
       @model.from_stop = nil
       assert_equal @model.from_stop_io_id, nil
       s = StopTest.fill_valid_model
       assert s.valid?
       s.save!
       @model.from_stop_io_id = s.io_id
       assert_equal @model.from_stop.io_id, @model.from_stop_io_id
     end

     test 'to_stop_io_id gets and sets to_stop' do
       assert @model.to_stop.present?
       assert_equal @model.to_stop.io_id, @model.to_stop_io_id
       @model.to_stop = nil
       assert_equal @model.to_stop_io_id, nil
       s = StopTest.fill_valid_model
       assert s.valid?
       s.save!
       @model.to_stop_io_id = s.io_id
       assert_equal @model.to_stop.io_id, @model.to_stop_io_id
     end


     #
     # GTFSABLE IMPORT/EXPORT
     #

     test "transfer row can be imported into a Transfer model" do
        model_class = Transfer
        test_class = TransferTest
        exceptions = [] #exceptions, in test
        #--- common part
        feed_row = test_class.valid_gtfs_feed_row
        #puts feed_row
        feed = FeedTest.fill_valid_model
        feed.save!
        model = model_class.new_from_gtfs(feed_row, feed)
        assert model.valid?, model.errors.to_a.to_s

        model_class.gtfs_cols.each do |model_attr, feed_col|
          next if exceptions.include? (model_attr)
          model_value = model.send(model_attr)
          model_value = model_value.to_s if model_value.is_a? Numeric
          model_value = model_value.to_gtfs if model_value.is_a? Time
          assert_equal feed_row[feed_col], model_value, "Testing " + model_attr.to_s + " vs " + feed_col.to_s
        end
        #------
      end

      test "a Transfer model can be exported into a gtfs row" do
        model_class = Transfer
        test_class = TransferTest
        exceptions = []
        #------ Common_part
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
        #-------------
      end


  end
end
