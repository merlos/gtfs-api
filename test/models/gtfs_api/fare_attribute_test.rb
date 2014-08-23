require 'test_helper'

module GtfsApi
  class FareAttributeTest < ActiveSupport::TestCase
    
    def self.fill_valid_fare_attribute
      unique = Time.now.to_f.to_s
      return FareAttribute.new(
        io_id: unique,
        price: 11.11,
        currency_type: 'EUR',
        payment_method: FareAttribute::ON_BOARD,
        transfers: FareAttribute::TWICE,
        transfer_duration: 10)
    end
    
    #
    # VALIDATIONS
    #
    
    test "valid fare_attribute" do
      f = FareAttributeTest.fill_valid_fare_attribute
      assert f.valid?, f.errors.full_messages
    end
    
    test "fare_attribute io_id presence required" do
      f = FareAttributeTest.fill_valid_fare_attribute
      f.io_id = nil
      assert f.invalid?, '_fare_id not present but fare_attributes valid'
    end
    
    test "price presence required" do
      f = FareAttributeTest.fill_valid_fare_attribute
      f.price = nil
      assert f.invalid?, 'price presence not required?'
    end
    
    test "currency_type presence required" do
      f = FareAttributeTest.fill_valid_fare_attribute
      f.currency_type = nil
      assert f.invalid?
    end
     
    
    test "currency_type length is exactly 3" do
      f = FareAttributeTest.fill_valid_fare_attribute
      f.currency_type = "EURO"
      assert f.invalid?
      
      f2 = FareAttributeTest.fill_valid_fare_attribute
      f2.currency_type = "EU"
      assert f.invalid? 
    end
    
    test "currency_type is a valid ISO4217 code" do
      f = FareAttributeTest.fill_valid_fare_attribute
      # TODO
    end 
    
    test "payment_method presence" do
      f = FareAttributeTest.fill_valid_fare_attribute
      f.payment_method = nil
      assert f.invalid?
    end
    
    test "payment_method range" do
      f = FareAttributeTest.fill_valid_fare_attribute
      #valid
      f.payment_method = 0
      assert f.valid?
      f.payment_method= 1
      assert f.valid?
      #invalid
      f.payment_method = 2
      assert f.invalid?
    end
    
    test "transfers range" do
     f = FareAttributeTest.fill_valid_fare_attribute
     f.transfers = nil
     assert f.valid?
     f.transfers = 0
     assert f.valid?
     f.transfers = 2
     assert f.valid?
     f.transfers = 3
     assert f.invalid?
   end
   
   test "uniqueness of _fare_id" do
     f = FareAttributeTest.fill_valid_fare_attribute
     f.save!
     f2 = FareAttributeTest.fill_valid_fare_attribute
     f2.io_id = f.io_id
     assert_raises ( ActiveRecord::RecordInvalid) {f2.save!}
     f3 = FareAttributeTest.fill_valid_fare_attribute
     f3.io_id="newValidId"
     assert_nothing_raised(ActiveRecord::RecordInvalid) {f3.save!}
   end
   
   #
   # ASSOCIATIONS
   #
   
   # requires fixtures:
   # - fare_attribute with io_id = '_fare_one'
   # - on fare_rules table, ONLY ONE fare_rule linking to _fare_one
   test "fare_attribute has_many fare_rules" do
     f = FareAttribute.find_by_io_id('_fare_one')
     assert (f.fare_rules.count == 1)
   end
  
  end #class 
end #module
