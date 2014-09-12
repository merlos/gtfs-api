module GtfsApi::V1
  class AgenciesController <  ApiController

    def index
      @agencies = GtfsApi::Agency.all
    end
    
    def show
      @agency = Agency.find(io_id: params[:id])
    end
    
  end
end