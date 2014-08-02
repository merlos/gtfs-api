require 'test_helper'

module GtfsApi
  class TransferTest < ActiveSupport::TestCase
    
    def fill_valid_transfer
      
      from = Stop.find_by_io_id('_stop_one')
      to = Stop.find_by_io_id('_stop_two')
       
      return Transfer.new( 
        from_stop:from,
        to_stop:to,
        transfer_type: Transfer::MIN_TRANSFER_TIME_REQUIRED,
        min_transfer_time: 3600)
    end
    
     test "valid transfer" do
       t= self.fill_valid_transfer
       assert t.valid?, t.errors.to_a
     end
     
     test "presence of from_stop and to_stop" do
       t = self.fill_valid_transfer
       t.from_stop = nil
       assert t.invalid?
       
       t = self.fill_valid_transfer
       t.to_stop = nil
       assert t.invalid?
     end
     
     test "valid transfer_type range" do
       # valid range is integer 0->3
       t = self.fill_valid_transfer
       t.transfer_type = 0
       assert t.valid?, t.errors.to_a
       
       t.transfer_type = 3
       assert t.valid?, t.errors.to_a
     end
     
     test 'invalid transfer_type range' do
       t = self.fill_valid_transfer
       
       assert t.valid?
       t.transfer_type = -100
       assert t.invalid?
              
       t1 = self.fill_valid_transfer
       t1.transfer_type = 4
       assert t1.invalid?
       
       t2 = self.fill_valid_transfer
       t2.transfer_type = 1.1
       assert t2.invalid?
       
       t3 = self.fill_valid_transfer
       t3.transfer_type = nil
       assert t3.invalid?
     end
  end
end
