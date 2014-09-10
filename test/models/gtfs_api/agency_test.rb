require 'test_helper'

module GtfsApi
  class AgencyTest < ActiveSupport::TestCase
    
    #fixtures :all #Load fixtures.
    
    #call this method to create a valid agency. Change values to invalidate
    def self.fill_valid_agency     
      Agency.new(
        io_id: 'AgencyID' + Time.new.to_f.to_s,
        name: 'Agency Name',
        url: 'http://www.agency-url.com',
        timezone: 'Madrid/Spain',
        lang: 'es',
        phone: '+34 600 100 200',
        fare_url: 'http://www.agency-fare-url.es')
    end
    
    # @return[Hash] Fills a hash with the data of an agency. The keys are the names
    #  of the cols of agency.txt file. The id of the agecy is unique.
    def self.valid_gtfs_feed_agency
      unique = Time.new.to_f.to_s
      {
        agency_name: 'gtfs agency name ' + unique,
        agency_id: 'gtfs-agency-' + unique,
        agency_url: 'http://github.com/merlos',
        agency_timezone: 'Madrid/Spain',
        agency_lang: 'es',
        agency_phone: '+34 555 3434',
        agency_fare_url: 'http://www.agency-fare-url.es'
      }
    end
    
    #
    # validation tests 
    #
    test "valid_agency" do
       a = AgencyTest.fill_valid_agency 
       assert a.valid?, 'A valid agency was claimed to be invalid; ' + a.errors.to_a.to_s  
       ## save
       assert a.save
    end
    
    test "agency io_id nil" do
      a = AgencyTest.fill_valid_agency
      a.io_id = nil
      assert a.valid? 
    end
    
    #TODO Why in the second assert a2 is not nil? in theory there is a limit:48 in the migration...
    test "agency io_id is too long" do
      a = AgencyTest.fill_valid_agency
      a.io_id = (0...10024).map { ('a'..'z').to_a[rand(26)] }.join
      assert a.valid?
      a.save!
      a2 = Agency.find_by_io_id(a.io_id)
      #puts a2.io_id
      assert_not a2.nil?
      
    end
    
    test "agency name presence " do 
      a = AgencyTest.fill_valid_agency 
      a.name = nil
      assert_not a.valid?, 'agency name shall be present; ' + a.errors.to_a.to_s  
    end
    
    test "agency url presence" do
      a = AgencyTest.fill_valid_agency 
      a.url = nil
      assert_not a.valid?, 'agency url shall be present; ' + a.errors.to_a.to_s  
    end
    
    test "agency url format" do
      a = AgencyTest.fill_valid_agency
      a.url = "http://www.foofoofoo.es"
      assert a.valid?, a.errors.to_a.to_s
      a.url = "https://barbarbar.es/drunk?param=holitas&vecinito"
      assert a.valid?, a.errors.to_a.to_s
      a.url = "http://this.is.a.valid%20url%20that%20has%20some%20stuff"
      assert a.valid?
      a.url = "ftp://www.fetepe.es"
      assert a.invalid?
      a2 = AgencyTest.fill_valid_agency
      a2.url = "/agency/absolute"
      assert a.invalid?
      
    end  
    
    test "agency timezone presence" do
      a = AgencyTest.fill_valid_agency 
      a.timezone = nil
      assert_not a.valid?, 'agency_timezone shall be present; ' + a.errors.to_a.to_s  
 
    end
    
    test "agency lang empty" do
      a = AgencyTest.fill_valid_agency 
      a.lang = nil
      assert a.valid?, 'agency_lang presence not required' + a.errors.to_a.to_s  
    end
    
    test "agency lang length" do    
      a = AgencyTest.fill_valid_agency 
      a.lang = 'e'
      assert_not a.valid?, 'agency_lang length < 2' + a.errors.to_a.to_s  
  
      a.lang = 'esp'
      assert_not a.valid?, 'agency_lang > 2' + a.errors.to_a.to_s  
    end
  

    # DATABASE AND ASSOCIATIONS
    
    test "agency io_id uniqueness" do
      a = AgencyTest.fill_valid_agency 
      a.io_id = "agency"
      a.save!
      a2 = AgencyTest.fill_valid_agency 
      a2.io_id = "agency" 
      assert_raises ( ActiveRecord::RecordInvalid) {a2.save!}
      a2.io_id = 'new_validagency_id'
      assert_nothing_raised ( ActiveRecord::RecordInvalid) {a2.save!}
    end
     
    test "agency has_many routes" do
      a = AgencyTest.fill_valid_agency;
      a.save!
      
      r1 = RouteTest.fill_valid_route
      r1.agency = a
      assert r1.valid?
      r1.save!
      
      r2 = RouteTest.fill_valid_route
      r2.agency = a
      assert r2.valid?
      r2.save!
      
      assert 2, a.routes.count      
    end
   
    test "agency has many fare_attributes" do
      a = AgencyTest.fill_valid_agency;
      a.save!
      # link 2 fare attributes
      fa1 = FareAttributeTest.fill_valid_fare_attribute
      fa1.agency = a
      fa1.save!
      fa2 = FareAttributeTest.fill_valid_fare_attribute
      fa2.agency = a
      fa2.save!
      assert_equal 2, a.fare_attributes.count
    end
    #
    # GTFSABLE Test
    #
    test 'gtfs agency file row can be imported into a valid model' do
      agency_row = AgencyTest.valid_gtfs_feed_agency
      a = Agency.new_from_gtfs(agency_row)
      assert a.valid?, a.errors.to_a.to_s
      #also check the values are the expected
      Agency.gtfs_cols.each do |k_api,k_feed|
        assert_equal agency_row[k_feed], a[k_api]
        #puts k_api.to_s + " " + a[k_api]
      end
    end
    
    test "agency model can be exported to gtfs feed row" do
      a = AgencyTest.fill_valid_agency
      agency_row = a.to_gtfs
      Agency.gtfs_cols.each do |model_attr, gtfs_col|
       assert_equal a[model_attr], agency_row[gtfs_col]
      end
    end
    
    
  end
end
