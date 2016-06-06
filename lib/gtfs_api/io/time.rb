#
#
# Extension of the standard Time class
#
# Added a few methods to handle import and export times
#
class ::Time

  # our time zero in gtfs: 0000-01-01 00:00:00 +00:00
  def self.gtfs_zero
    Time.new(0,1,1,0,0,0,'+00:00')
  end

  #
  # @return[String] in format HH:MM:SS, where HH can be > 23, ex: "25:33:25"
  #
  def to_gtfs
    secs = self - Time.gtfs_zero
    h = (secs / 3600)
    m = (h - h.floor) * 60
    s = (m - m.floor) * 60
    hh =  h > 10 ? h.floor.to_s : '0' + h.floor.to_s
    mm =  m > 10 ? m.floor.to_s : '0' + m.floor.to_s
    ss =  s > 10 ? s.round.to_s : '0' + s.round.to_s
    "#{hh}:#{mm}:#{ss}"
  end

  def self.is_gtfs_valid? (val)
    !(hh,mm,ss = val.scan(/^0?(\d+):([0-5][0-9]):([0-5][0-9])+$/)[0]).nil?
  end
  #
  # Converts into Time object a string in GTFS time format
  #
  # @param val[String] Time with the format: HH:MM:SS or H:MM:SS, where HH can be >23
  #
  # @return [Time] if the string has the correct format. nil otherwise
  def self.new_from_gtfs(val)
    #puts is a string => parse
    if (hh,mm,ss = val.scan(/^0?(\d+):([0-5][0-9]):([0-5][0-9])+$/)[0]).nil?
      return
    end
    Time.new(0,1,(hh.to_f/24).floor+1,hh.to_f%24,mm,ss,'+00:00')
  end

end
