require 'test_helper'

module GtfsApi
  class ShapeTest < ActiveSupport::TestCase
    # test "the truth" do
    #   assert true
    # end
    
    def fill_valid_shape 
      return Shape.new(
      io_id: 'unique',
      pt_lat: '30.1',
      pt_lon: '30.2',
      pt_sequence: 1,
      dist_traveled: 3.3  
      )
    end
    
    test 'valid shape' do
      s = self.fill_valid_shape
      assert s.valid? 
    end
    
    test 'io_id presence required' do
      s = self.fill_valid_shape
      s.io_id = nil
      assert s.invalid?
    end 
    
    test 'pt lat and lon presence required' do
      s = self.fill_valid_shape
      s.pt_lat = nil
      assert s.invalid?
      s = self.fill_valid_shape
      s.pt_lon = nil
      assert s.invalid? 
    end
    
    test 'pt lat and lon range' do
      s = self.fill_valid_shape
      s.pt_lat = -90.1
      assert s.invalid?
      s = self.fill_valid_shape
      s.pt_lat = 90.1
      assert s.invalid?

      s = self.fill_valid_shape
      s.pt_lon = -180.1
      assert s.invalid?
      s = self.fill_valid_shape
      s.pt_lon = 180.1
      assert s.invalid?
    end
    
    test 'pt sequence presence' do
      s = self.fill_valid_shape
      s.pt_sequence = nil
      assert s.invalid?
    end
    
    test 'pt seq has to be a positive integer' do
      s = self.fill_valid_shape
      s.pt_sequence = 1.1
      assert s.invalid?
      
      s = self.fill_valid_shape
      s.pt_sequence = 0
      assert s.valid?
      
      s.pt_sequence = -1
      assert s.invalid?
    end
            
  end
end
