require 'test_helper'

module GtfsApi
  class FareAttributeTest < ActiveSupport::TestCase
    
    def fill_valid_fare_attribute
      return FareAttribute.new(
        io_id: 'Fare',
        price: 11.11,
        currency_type: 'EUR',
        payment_method: FareAttribute::PAID_ON_BOARD,
        transfers: FareAttribute::TRANSFER_TWICE,
        transfer_duration: 10)
    end
    
    test "valid fare_attribute" do
      f = self.fill_valid_fare_attribute
      assert f.valid?, f.errors.full_messages
    end
    
    test "fare_attribute io_id presence required" do
      f = self.fill_valid_fare_attribute
      f.io_id = nil
      assert f.invalid?, '_fare_id not present but fare_attributes valid'
    end
    
    test "price presence required" do
      f = self.fill_valid_fare_attribute
      f.price = nil
      assert f.invalid?, 'price presence not required?'
    end
    
    test "currency_type presence required" do
      f = self.fill_valid_fare_attribute
      f.currency_type = nil
      assert f.invalid?
    end
     
    
    test "currency_type length is exactly 3" do
      f = self.fill_valid_fare_attribute
      f.currency_type = "EURO"
      assert f.invalid?
      
      f2 = self.fill_valid_fare_attribute
      f2.currency_type = "EU"
      assert f.invalid? 
    end
    
    test "currency_type is a valid ISO4217 code" do
      f = self.fill_valid_fare_attribute
      # TODO
    end 
    
    test "payment_method presence" do
      f = self.fill_valid_fare_attribute
      f.payment_method = nil
      assert f.invalid?
    end
    
    test "payment_method range" do
      f = self.fill_valid_fare_attribute
      #valid
      f.payment_method = 0
      assert f.valid?
      f.payment_method= 1
      assert f.valid?
      #invalid
      f.payment_method = 2
      assert f.invalid?
    end
    
    test  "transfers range" do
     f = self.fill_valid_fare_attribute
     f.transfers = nil
     assert f.valid?
     f.transfers = 0
     assert f.valid?
     f.transfers = 2
     assert f.valid?
     f.transfers = 3
     assert f.invalid?
   end
   
    
   # DATABASE TESTS 
   
   test "uniqueness of _fare_id" do
     f = self.fill_valid_fare_attribute
     f.save!
     f2 = self.fill_valid_fare_attribute
     assert_raises ( ActiveRecord::RecordInvalid) {f2.save!}
     f3 = self.fill_valid_fare_attribute
     f3.io_id="newValidId"
     assert_nothing_raised(ActiveRecord::RecordInvalid) {f3.save!}
   end
    
    
    
  end #class 
end #module
