class Platform::Developer::RegistrationController < Platform::Developer::BaseController

  skip_filter :validate_developer

  def index
        
  end

  def proceed
    unless Platform::Config.current_user_is_developer?
      Platform::Developer.find_or_create(Platform::Config.current_user)
    end  
    redirect_to(:controller => "/platform/developer/apps")
  end
  
end
