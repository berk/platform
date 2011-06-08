class Platform::Admin::DevelopersController < Platform::Admin::BaseController

  def index
    @developers = Platform::Developer.filter(:params => params)
  end
  
end
