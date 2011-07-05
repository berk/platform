class Platform::Api::AppsController < Platform::Api::BaseController
  def index
    render_response(Platform::Application.all) 
  end

private 

  def model_class
    Platform::Application
  end
  
end