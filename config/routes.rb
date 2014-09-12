GtfsApi::Engine.routes.draw do
  #namespace :gtfs do
    namespace :v1 do
      resources :agencies, only: [:index, :show], param: :io_id
      resources :feed_infos, only: [:index,:show], param: :io_id,  as: :feeds
    end
    #end
end
