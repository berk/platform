class Platform::OauthController < Platform::BaseController
  
  include SslRequirement
  ssl_required :authorize, :request_token, :invalidate_token, :validate_token, :revoke, :invalidate

  skip_before_filter :validate_guest_user  

  # http://tools.ietf.org/html/draft-ietf-oauth-v2-16#section-4.1
  # supports response_type = code, token 
  def authorize
    if Platform::Config.current_user_is_guest?
      save_login_redirect_params
      return redirect_to(:controller => "/login")
    end
  
    if request_param(:client_id).blank?
      return render_response(:error_description => "client_id must be provided", :error => :invalid_request)
    end

    unless client_application
      return render_response(:error_description => "invalid client application id", :error => :unauthorized_client)
    end

    if request_param(:response_type).blank?
      return render_response(:error_description => "response_type must be provided", :error => :invalid_request)
    end
    
    unless ["code","token"].include?(request_param(:response_type))
      return render_response(:error_description => "only code and token response type are currently supported", :error => :unsupported_response_type)
    end
    
    if redirect_url.blank?
      return render_response(:error_description => "redirect_uri must be provided as a parameter or in the application callback_url field", :error => :invalid_request)
    end
    
    unless is_redirect_url_valid?(redirect_url)
      return render_response(:error_description => "redirect_uri cannot point to a different server than from the one it sent a request", :error => :invalid_request)
    end
    
    send("oauth2_authorize_#{request_param(:response_type)}")
  end

  # http://tools.ietf.org/html/draft-ietf-oauth-v2-16#section-4.2
  # supported grant_type = authorization_code, password
  # unsupported grant_types = client_credentials, refresh_token
  def request_token
    if request_param(:client_id).blank?
      return render_response(:error_description => "client_id must be provided", :error => :invalid_request)
    end

    unless client_application
      return render_response(:error_description => "invalid client application id", :error => :unauthorized_client)
    end

    if request_param(:grant_type).blank?
      return render_response(:error_description => "grant_type must be provided", :error => :invalid_request)
    end
    
    unless ["authorization_code", "password"].include?(request_param(:grant_type))
      return render_response(:error_description => "only authorization_code and password response type are currently supported", :error => :unsupported_grant_type)
    end

    if request_param(:grant_type) == "authorization_code"
      if request_param(:code).blank?
        return render_response(:error_description => "code must be provided", :error => :invalid_request)
      end
      if redirect_url.blank?
        return render_response(:error_description => "redirect_uri must be provided as a parameter or in the application callback_url field", :error => :invalid_request)
      end
      
      unless is_redirect_url_valid?(redirect_url)
        return render_response(:error_description => "redirect_uri cannot point to a different server than from the one it sent a request", :error => :invalid_request)
      end
    elsif request_param(:grant_type) == "password"
      if request_param(:username).blank?
        return render_response(:error_description => "username must be provided", :error => :invalid_request)
      end
      if request_param(:password).nil?
        return render_response(:error_description => "password must be provided", :error => :invalid_request)
      end
    end

    send("oauth2_request_token_#{request_param(:grant_type)}")
  end 
  alias :token :request_token
  
  def validate_token
    token = Platform::Oauth::OauthToken.find_by_token(request_param(:access_token))
    if token && token.authorized?
      render_response({:result => "OK"}, {:type => :json})
    else
      render_response({:error => :invalid_token, :error_description => "token not found"}, {:type => :json})
    end
  end

  def invalidate_token
    token = Platform::Oauth::OauthToken.find_by_token(request_param(:access_token))
    token.invalidate! if token
    render_response({:result => "OK"}, {:type => :json})
  end
  
  def xd
  	render :layout => false
  end

private

  def request_param(key)
    params[key]
  end

  def client_application
    @client_application ||= Platform::Application.find_by_key(request_param(:client_id)) || Platform::Application.find_by_id(request_param(:client_id)) 
  end

  def redirect_url
    @redirect_url ||= request_param(:redirect_url) || request_param(:redirect_uri)|| client_application.callback_url
  end

  # web_server, user_agent
  def type
    request_param(:type) || "web_server"
  end

  def scope
    request_param(:scope) || "basic"
  end

  # needs to be configured through Platform::Config
  def authenticate_user(username, password)
    User.authenticate(username, password)
  end

  # request token with grant_type = authorization_code
  def oauth2_request_token_authorization_code
    verifier = Platform::Oauth::RequestToken.find(:first, :conditions => ["application_id = ? and token = ? and valid_to > ?", 
                                                             client_application.id, request_param(:code), Time.now])
    unless verifier
      return render_response(:error_description => "invalid verification code", :error => :invalid_request)
    end
    
    if verifier.callback_url != redirect_url
      return render_response(:error_description => "invalid redirection url. it must match the url used for the code request.", :error => :invalid_request)
    end
    
    token = client_application.create_request_token(:user=>verifier.user, :scope=>verifier.scope)
    Platform::ApplicationUser.touch(client_application)
    return render_response(:access_token => token.token, :expires_in => (token.valid_to.to_i - Time.now.to_i))
  end

  # request token with grant_type = password
  def oauth2_request_token_password
    user = authenticate_user(request_param(:username), request_param(:password))
    unless user
      return render_response(:error_description => "invalid username and/or password", :error => :invalid_request)
    end
    
    token = client_application.create_access_token(:user=>user, :scope=>scope)
    render_response({:access_token => token.token, :expires_in => (token.valid_to.to_i - Time.now.to_i)}, {:type => :json})
  end

  # authorize with response_type = code
  def oauth2_authorize_code
    if request.post?
      if params[:authorize] == '1'
        code = client_application.create_request_token(:user=>Platform::Config.current_user, :callback_url=>redirect_url, :scope => scope)
        Platform::ApplicationUser.touch(client_application)
        return render_response(:code => code.code, :expires_in => (code.valid_to.to_i - Time.now.to_i))
      end
      
      if client_application.auto_signin?
        return redirect_to(Platform::Config.default_url)
      end
      
      return render_response(:error => :access_denied)
    end   

    render_action("authorize")
  end

  # authorize with response_type = token
  def oauth2_authorize_token
    if request.post?
      if params[:authorize] == '1'
        token = client_application.create_access_token(:user=>Platform::Config.current_user, :scope=>scope)
        Platform::ApplicationUser.touch(client_application)
        return render_response(:access_token => token.token, :expires_in => (token.valid_to.to_i - Time.now.to_i))
      end

      if client_application.auto_signin?
        return redirect_to(Platform::Config.default_url)
      end

      return render_response(:error => :access_denied)
    end   

    render_action("authorize")
  end

  def is_redirect_url_valid?(url)
    if redirect_url == "#{client_application.id}://authorize"
      # make sure the user_agent is an iphone
      return true
    end
    true
  end

  def render_response(response_params, opts = {})
    response_params[:state] = request_param(:state) if request_param(:state)
    
    # we need to support json and redirect based method as well
    
    if opts[:type] == :json
      return render(:json => response_params.to_json)
    end  
    
    if redirect_url.blank?
      @error = trl(response_params[:error_description])
      return render_action("authorize_failure")
    end

    response_query=response_params.collect{|key, value| "#{key}=#{value}"}.join("&")
    
    #support the client_id://authorize - schema for iOS SDK
    if redirect_url == "#{client_application.key}://authorize"
      redirect_to("#{redirect_url}?#{response_query}")
    else
      redirect_uri = URI.parse(redirect_url)
      redirect_uri.query = redirect_uri.query.blank? ? response_query : redirect_uri.query + "&#{response_query}" 
      redirect_to(redirect_uri.to_s)
    end
  end
  
  def render_action(action)
    if mobile_device?
      return render(:action => "#{action}_mobile", :layout => false)
    end
    
    render(:action => action)
  end    

end
