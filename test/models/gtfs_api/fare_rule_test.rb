require 'test_helper'

module GtfsApi
  class FareRuleTest < ActiveSupport::TestCase
     
    def fill_valid_fare_rule 
      # TODO check how to generate a valid fare attribute using the FareAttibuteTest.fill_valid_fare_attribute
      
      #Note, that io_id of fare attribute shall be unique, so to be able to call fill_valid_fare_rule
      # more than once in the same test we have to generate different io_ids.
      fa = FareAttribute.new(
        io_id: (0...8).map { (65 + rand(26)).chr }.join,
        price: 11.11,
        currency_type: 'EUR',
        payment_method: FareAttribute::PAID_ON_BOARD)
      
      assert fa.valid? 
      fa.save      
      return FareRule.new( 
        fare: fa,
        origin_id: 'zone_init',
        destination_id: 'zone_end',
        contains_id: 'contains_zone')
    end
    
     test 'a valid fare_rule is valid' do
      f = self.fill_valid_fare_rule
       assert f.valid?, f.errors.to_a
     end
     
     test 'fare_id presence required' do
      f = self.fill_valid_fare_rule
       f.fare = nil
       assert f.invalid?, f.errors.to_a       
     end
     
     test 'fare presence required' do
       f = self.fill_valid_fare_rule
       f.fare = nil
       assert f.invalid?

     end
     
    
     #
     # Associations
     #
     
     #
     # requires fixtures with:
     #  - fare_rule that belongs_to a fare_attribute with io_id '_fare_one'
     test 'fare_rule belongs_to fare_attribute' do
       
       fare_attribute = FareAttribute.find_by_io_id('_fare_one')
       f = FareRule.where(fare: fare_attribute).first
       #check if we can access to the record
       assert (f.fare.io_id=='_fare_one')
       
     end
  end
end
