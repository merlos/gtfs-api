require 'date'

class ::Date
  # @return[String] in the format "YYYYMMDD"
  def to_gtfs
    self.strftime("%Y%m%d")
  end
end
