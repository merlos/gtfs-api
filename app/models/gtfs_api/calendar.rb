module GtfsApi
  class Calendar < ActiveRecord::Base
    
    include GtfsApi::Io::Models::Concerns::Gtfsable
    set_gtfs_file :calendar
    set_gtfs_col :service_io_id, :service_id
    set_gtfs_col :monday
    set_gtfs_col :tuesday
    set_gtfs_col :wednesday
    set_gtfs_col :thursday
    set_gtfs_col :friday
    set_gtfs_col :saturday
    set_gtfs_col :sunday
    set_gtfs_col :start_date
    set_gtfs_col :end_date
    
    
    # VALIDATIONS
    validates :service, presence:true 
    validates :monday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :tuesday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :wednesday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :thursday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :friday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :saturday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :sunday, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    validates :start_date, presence: true
    validates :end_date, presence: true
    validates :feed, presence: true
    
    
    # ASSOCIATIONS  
    belongs_to :service
    belongs_to :feed  
    
    has_many :trips, foreign_key: 'service_id', primary_key: 'service_id'
    
    #VIRTUAL ATTRIBUTES
    attr_accessor :service_io_id
    
    def service_io_id
      service.present? ? service.io_id : nil
    end
    
    def service_io_id=(val)
      self.service = Service.find_by!(io_id: val)
    end
      
    # CONSTANTS
    AVAILABLE = 1
    NOT_AVAILABLE = 0
    
    Available = {
      :yes => AVAILABLE,
      :no => NOT_AVAILABLE
    }    
  
    Week = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
    WeekDays = [:monday, :tuesday, :wednesday, :thursday, :friday]
    Weekend = [:saturday, :sunday]
  end
end
