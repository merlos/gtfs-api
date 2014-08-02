require 'test_helper'

module GtfsApi
  class TransferTest < ActiveSupport::TestCase
    
    def fill_valid_transfer 
      return Transfer.new( 
        io_from_stop_id: 'from_stop_id',
        io_to_stop_id: 'to_stop_id',
        transfer_type: Transfer::MIN_TRANSFER_TIME_REQUIRED,
        min_transfer_time: 3600)
    end
    
     test "valid transfer" do
       assert self.fill_valid_transfer.valid?
     end
     
     test "presence of io_from_stop_id and io_to_stop_id" do
       t = self.fill_valid_transfer
       t.io_from_stop_id = nil
       assert t.valid?
       
       t = self.fill_valid_transfer
       t.io_to_stop_id = nil
       assert t.valid?
     end
     
     test "valid transfer_type range" do
       # valid range is integer 0->3
       t = self.fill_valid_transfer
       t.transfer_type = 0
       assert t.valid?
       
       t.transfer_type = 3
       assert t.valid?
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
