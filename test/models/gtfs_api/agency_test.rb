require 'test_helper'

module GtfsApi
  class AgencyTest < ActiveSupport::TestCase
    # test "the truth" do
    #   assert true
    # end
    fixtures :all
    #call this method to create a valid agency. Change values to invalidate
    def self.fill_valid_agency     
      return Agency.new(
        io_id: 'AgencyID',
        name: 'Agency Name',
        url: 'http://www.agency-url.com',
        timezone: 'Madrid/Spain',
        lang: 'es',
        phone: '+34 600 100 200',
        fare_url: 'http://www.agency-fare-url.es')
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
  
  
    # DATABASE TESTS based on fixtures
    
    test "agency io_id uniqueness" do
      a = AgencyTest.fill_valid_agency 
      a.save!
      a2 = AgencyTest.fill_valid_agency 
      assert_raises ( ActiveRecord::RecordInvalid) {a2.save!}
      a2.io_id = 'new_validagency_id'
      assert_nothing_raised ( ActiveRecord::RecordInvalid) {a2.save!}
    end
     
    test "agency has_many routes" do
      #defined in fixtures
      a = Agency.find_by_io_id('_agency_one'); 
      assert (a.routes.count == 2)
    end
    
  end
end
