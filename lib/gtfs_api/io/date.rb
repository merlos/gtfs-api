require 'date'

class ::Date
  # @return[String] in the format "YYYY-MM-DD"
  def to_gtfs
    self.strftime("%Y-%m-%d")
  end
end
