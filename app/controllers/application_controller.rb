class ApplicationController < ActionController::Base
  
  def current_user
    @current_user ||= (Platform::PlatformUser.find_by_id(session[:platform_user_id]) unless session[:platform_user_id].blank?) || Platform::PlatformUser.new
  end
  helper_method :current_user

  def login!(user)
    session[:platform_user_id] = user.id
  end

  def logout!
    session[:platform_user_id] = nil
  end  

end
