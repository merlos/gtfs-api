Rails.application.routes.draw do

  mount GtfsApi::Engine => "/gtfs"
end
