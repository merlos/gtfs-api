module GtfsApi
  class Engine < ::Rails::Engine
    isolate_namespace GtfsApi
    
    # Autoload from lib directory
    config.autoload_paths << File.expand_path('../../', __FILE__)
       
  end
end
