class Platform::ApiController < ActionController::Base
  before_filter :before_api_call
  after_filter  :after_api_call
  

protected

  # should be overloaded by the extening base class
  def authenticate
    authenticate_via_oauth 

    if oauth_attempted? and not logged_in?
      raise Exception.new('Invalid access token')
    else
      redirect_to_login unless allow_public?
    end
  end

  # should be overloaded by the extening base class
  def authenticate_via_oauth
    user = access_token.try(:user)
    Platform::Config.init(user) if user
  end

  def access_token
    unless defined?(@access_token)
      @access_token = Platform::Application.find_token(params[:access_token])
    end

    # Ticket 18799 - work around Oauth2-0.1.0
    if @access_token.nil? && access_token_param
      @access_token = Platform::Oauth::AccessToken.first(:conditions => {:token => access_token_param, :invalidated_at => nil})
    end

    @access_token
  end

  def access_token_param
    @access_token_param ||= params[:access_token] || params[:oauth_token]
  end

  def client_app
    @client_app ||= access_token.try(:application)
  end

  def logged_in?
    not Platform::Config.current_user_is_guest?
  end
  
  def allow_public?
    true # should be moved to the platform configuration
  end
  
  def oauth_attempted?
    access_token_param || request.env['Authorization'] =~ /oauth/i
  end
  
  def enabled?
    Platform::Config.enable_api?
  end
  
private

  def redirect_to_login
    redirect_to("/login")
  end

  def before_api_call
    return unless Platform::Config.enable_api_log?
    @api_log = Platform::ApplicationLog.create(:application => client_app, :user => Platform::Config.current_user, :event => "#{params[:controller]}-#{params[:action]}", :data => params)
  end
  
  def after_api_call
    return unless Platform::Config.enable_api_log?
    @api_log.update_attributes(:user => Platform::Config.current_user)    
  end
end
