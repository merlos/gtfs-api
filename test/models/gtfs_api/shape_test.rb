require 'test_helper'

module GtfsApi
  class ShapeTest < ActiveSupport::TestCase
    # test "the truth" do
    #   assert true
    # end
    
    def self.fill_valid_shape 
      return Shape.new(
      io_id: 'unique',
      pt_lat: '30.1',
      pt_lon: '30.2',
      pt_sequence: 1,
      dist_traveled: 3.3  
      )
    end
    
    def self.valid_gtfs_feed_shape
      return { 
      shape_id: 'unique',
      shape_pt_lat: '30.1',
      shape_pt_lon: '30.2',
      shape_pt_sequence: '1',
      shape_dist_traveled: '3.3'
      }
    end
    test 'valid shape' do
      s = ShapeTest.fill_valid_shape
      assert s.valid? 
    end
    
    test 'io_id presence required' do
      s = ShapeTest.fill_valid_shape
      s.io_id = nil
      assert s.invalid?
    end 
    
    test 'pt lat and lon presence required' do
      s = ShapeTest.fill_valid_shape
      s.pt_lat = nil
      assert s.invalid?
      s = ShapeTest.fill_valid_shape
      s.pt_lon = nil
      assert s.invalid? 
    end
    
    test 'pt lat and lon range' do
      s = ShapeTest.fill_valid_shape
      s.pt_lat = -90.1
      assert s.invalid?
      s = ShapeTest.fill_valid_shape
      s.pt_lat = 90.1
      assert s.invalid?

      s = ShapeTest.fill_valid_shape
      s.pt_lon = -180.1
      assert s.invalid?
      s = ShapeTest.fill_valid_shape
      s.pt_lon = 180.1
      assert s.invalid?
    end
    
    test 'pt sequence presence' do
      s = ShapeTest.fill_valid_shape
      s.pt_sequence = nil
      assert s.invalid?
    end
    
    test 'pt seq has to be a positive integer' do
      s = ShapeTest.fill_valid_shape
      s.pt_sequence = 1.1
      assert s.invalid?
      
      s = ShapeTest.fill_valid_shape
      s.pt_sequence = 0
      assert s.valid?
      
      s.pt_sequence = -1
      assert s.invalid?
    end
     
    # ASSOCIATIONS
    
    
    # GTFSABLE tests
    
    test "shape row can be imported into a Shape model" do
       model_class = Shape
       test_class = ShapeTest
       exceptions = [] #exceptions, in test
       #--- common part
       feed_row = test_class.send('valid_gtfs_feed_' + model_class.to_s.split("::").last.underscore)
       #puts feed_row
       model = model_class.new_from_gtfs(feed_row)
       assert model.valid?
       model_class.gtfs_cols.each do |model_attr, feed_col|
         next if exceptions.include? (model_attr)
         model_value = model.send(model_attr)
         model_value = model_value.to_s if model_value.is_a? Numeric
         assert_equal feed_row[feed_col], model_value, "Testing " + model_attr.to_s + " vs " + feed_col.to_s
       end
       #------
     end
   
     test "a Shape model can be exported into a gtfs row" do
       model_class = Shape
       test_class = ShapeTest
       exceptions = []
       #------ Common_part
       model = test_class.send('fill_valid_' + model_class.to_s.split("::").last.underscore)
       feed_row = model.to_gtfs
       #puts feed_row
       model_class.gtfs_cols.each do |model_attr, feed_col|
         next if exceptions.include? (model_attr)
         feed_value = feed_row[feed_col]
         feed_value = feed_value.to_f if model.send(model_attr).is_a? Numeric
         assert_equal model.send(model_attr), feed_value, "Testing " + model_attr.to_s + " vs " + feed_col.to_s
       end
     end
          
  end
end
