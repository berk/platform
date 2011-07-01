class Platform::Admin::DevelopersController < Platform::Admin::BaseController

  def index
    @developers = Platform::Developer.filter(:params => params, :filter => Platform::DeveloperFilter)
  end
  
end
