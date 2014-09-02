require 'test_helper'

module GtfsApi
  class TransferTest < ActiveSupport::TestCase
    
    def self.fill_valid_transfer
      from = Stop.find_by_io_id('_stop_one')
      to = Stop.find_by_io_id('_stop_two')
       
      return Transfer.new( 
        from_stop:from,
        to_stop:to,
        transfer_type: Transfer::MIN_TRANSFER_TIME_REQUIRED,
        min_transfer_time: 3600)
    end
    
    def self.valid_gtfs_feed_transfer 
      from = Stop.find_by_io_id('_stop_one')
      to = Stop.find_by_io_id('_stop_two')
      {
        from_stop_id: from.io_id,
        to_stop_id: to.io_id,
        transfer_type: "0",
        min_transfer_time: "3600"
      }
    end
    
     test "valid transfer" do
       t= TransferTest.fill_valid_transfer
       assert t.valid?, t.errors.to_a
     end
     
     test "presence of from_stop and to_stop" do
       t = TransferTest.fill_valid_transfer
       t.from_stop = nil
       assert t.invalid?
       
       t = TransferTest.fill_valid_transfer
       t.to_stop = nil
       assert t.invalid?
     end
     
     test "valid transfer_type range" do
       # valid range is integer 0->3
       t = TransferTest.fill_valid_transfer
       t.transfer_type = 0
       assert t.valid?, t.errors.to_a
       
       t.transfer_type = 3
       assert t.valid?, t.errors.to_a
     end
     
     test 'invalid transfer_type range' do
       t = TransferTest.fill_valid_transfer
       
       assert t.valid?
       t.transfer_type = -100
       assert t.invalid?
              
       t1 = TransferTest.fill_valid_transfer
       t1.transfer_type = 4
       assert t1.invalid?
       
       t2 = TransferTest.fill_valid_transfer
       t2.transfer_type = 1.1
       assert t2.invalid?
       
       t3 = TransferTest.fill_valid_transfer
       t3.transfer_type = nil
       assert t3.invalid?
     end
     
     test 'from_stop_io_id cannot set nil' do
       t = TransferTest.fill_valid_transfer
       assert_raises ( ActiveRecord::RecordNotFound) {t.from_stop_io_id = nil}
     end
      
     test 'to_stop_io_id cannot set nil' do
       t = TransferTest.fill_valid_transfer
       assert_raises ( ActiveRecord::RecordNotFound) {t.to_stop_io_id = nil}
     end
    
     test 'from_stop_io_id gets and sets from_stop' do
       t = TransferTest.fill_valid_transfer
       assert t.from_stop.present?
       assert_equal t.from_stop.io_id, t.from_stop_io_id
       t.from_stop = nil
       assert_equal t.from_stop_io_id, nil
       s = StopTest.fill_valid_stop
       assert s.valid?
       s.save!
       t.from_stop_io_id = s.io_id
       assert_equal t.from_stop.io_id, t.from_stop_io_id
     end
     
     test 'to_stop_io_id gets and sets to_stop' do
       t = TransferTest.fill_valid_transfer
       assert t.to_stop.present?
       assert_equal t.to_stop.io_id, t.to_stop_io_id
       t.to_stop = nil
       assert_equal t.to_stop_io_id, nil
       s = StopTest.fill_valid_stop
       assert s.valid?
       s.save!
       t.to_stop_io_id = s.io_id
       assert_equal t.to_stop.io_id, t.to_stop_io_id
     end
     
     
     
    
     test "transfer row can be imported into a Transfer model" do
        model_class = Transfer
        test_class = TransferTest
        exceptions = [] #exceptions, in test
        #--- common part
        feed_row = test_class.send('valid_gtfs_feed_' + model_class.to_s.split("::").last.underscore)
        #puts feed_row
        model = model_class.new_from_gtfs(feed_row)
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
        model = test_class.send('fill_valid_' + model_class.to_s.split("::").last.underscore)
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
    
     
  end
end
