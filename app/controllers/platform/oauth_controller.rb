#--
# Copyright (c) 2011 Michael Berkovich, Geni Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

class Platform::OauthController < Platform::BaseController
  
  include SslRequirement
  ssl_required :authorize, :request_token, :invalidate_token, :validate_token, :revoke, :invalidate

  skip_before_filter :validate_guest_user  

  # http://tools.ietf.org/html/draft-ietf-oauth-v2-16#section-4.1
  # supports response_type = code, token 
  def authorize
    if Platform::Config.current_user_is_guest?
      save_oauth_login_redirect_params
      return redirect_to(:controller => Platform::Config.login_url, :display => params[:display])
    end
  
    if request_param(:client_id).blank?
      return redirect_with_response(:error_description => "client_id must be provided", :error => :invalid_request)
    end

    unless client_application
      return redirect_with_response(:error_description => "invalid client application id", :error => :unauthorized_client)
    end

    if redirect_url.blank? and not xd?
      return redirect_with_response(:error_description => "redirect_uri must be provided as a parameter or in the application callback_url property", :error => :invalid_request)
    end

    if request_param(:response_type).blank?
      return redirect_with_response(:error_description => "response_type must be provided", :error => :invalid_request)
    end
    
    unless ["code","token"].include?(request_param(:response_type))
      return redirect_with_response(:error_description => "only code and token response types are currently supported", :error => :unsupported_response_type)
    end

    unless redirect_url_valid?(redirect_url)
      return redirect_with_response(:error_description => "redirect_uri cannot point to a different server than from the one it sent a request", :error => :invalid_request)
    end
    
    send("oauth2_authorize_#{request_param(:response_type)}")
  end

  def xd?
    ['popup', 'hidden'].include?(params[:display])
  end

  # http://tools.ietf.org/html/draft-ietf-oauth-v2-16#section-4.2
  # supported grant_type = authorization_code, password, refresh_token
  # unsupported grant_types = client_credentials 
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
    
    unless ["authorization_code", "password", "refresh_token"].include?(request_param(:grant_type))
      return render_response(:error_description => "only authorization_code, password and refresh_token grant types are currently supported", :error => :unsupported_grant_type)
    end

    send("oauth2_request_token_#{request_param(:grant_type)}")
  end 
  alias :token :request_token
  
  def validate_token
    token = Platform::Oauth::OauthToken.find_by_token(request_param(:access_token))
    if token && token.authorized?
      render_response(:result => "OK")
    else
      render_response(:error => :invalid_token, :error_description => "invalid token")
    end
  end

  # add jsonp support
  def invalidate_token
    token = Platform::Oauth::OauthToken.find_by_token(request_param(:access_token))
    token.invalidate! if token
    render_response(:result => "OK")
  end
  
  def deauthorize
    unless Platform::Config.current_user_is_guest?
      client_application.deauthorize_user if client_application
    end
    render_response(:result => "OK")
  end

  def logout
    if Platform::Config.site_user_info_enabled?
      begin
        eval(Platform::Config.logout_method)
      rescue Exception => ex
        raise Platform::Exception.new("Failed to execute #{Platform::Config.logout_method} with exception: #{ex.message}")
      end
    else
      # handle default logout strategy
    end
    
    render_response(:result => "OK")
  end
  
  def xd
  	render :layout => false
  end

  def status
    if Platform::Config.current_user_is_guest?
      return redirect_with_response(:status => "unknown")
    end
    
    unless client_application
      return redirect_with_response(:status => "unknown")
    end

    # implement authorized user
    if client_application.authorized_user?
      # add access token to the redirect
      access_token = client_application.create_access_token(:user=>Geni.current_user, :scope=>scope)
      refresh_token = client_application.create_refresh_token(:user=>Geni.current_user, :scope=>scope)
      return redirect_with_response(:status => "authorized", :access_token => access_token.token, :refresh_token => refresh_token.token, :expires_in => (access_token.valid_to.to_i - Time.now.to_i))
    end
    
    redirect_with_response(:status => "unauthorized")
  end 

private

  def save_oauth_login_redirect_params
    session[:oauth_login_redirect_params] = params
  end
  
  def valid_signature?
    # enable signature verification, always
    return true if request_param(:sig).blank?
    payload = ""
    params.keys.sort.each do |key|
      next if ['controller', 'action', 'sig'].include?(key.to_s)
      payload << "#{key}=#{params[key]}"
    end
    payload << client_application.secret
    digested = Digest::MD5.hexdigest(payload)
    digested == request_param(:sig)
  end

  def request_param(key)
    params[key]
  end

  def client_application
    return nil if request_param(:client_id).blank?  
  
    @client_application ||= begin
      app = Platform::Application.find_by_id(request_param(:client_id)) if request_param(:client_id).match(/^[\d]+$/)
      app || Platform::Application.find_by_key(request_param(:client_id))
    end
  end

  def redirect_url
    @redirect_url ||= request_param(:redirect_url) || request_param(:redirect_uri) || client_application.try(:callback_url)
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
    if request_param(:code).blank?
      return render_response(:error_description => "code must be provided", :error => :invalid_request)
    end
    
    verifier = Platform::Oauth::RequestToken.find(:first, :conditions => ["application_id = ? and token = ? and valid_to > ? and invalidated_at is null", 
                                                             client_application.id, request_param(:code), Time.now])
    unless verifier
      return render_response(:error_description => "invalid verification code", :error => :invalid_request)
    end
    
    if verifier.callback_url != redirect_url
      return render_response(:error_description => "redirection url must match the url used for the code request", :error => :invalid_request)
    end
    
    access_token = verifier.exchange!
    refresh_token = client_application.create_refresh_token(:user=>access_token.user, :scope=>scope)
    Platform::ApplicationUser.touch(client_application, access_token.user)
    render_response(:access_token => access_token.token, :refresh_token => refresh_token.token, :expires_in => (access_token.valid_to.to_i - Time.now.to_i))
  end

  # request token with grant_type = password
  def oauth2_request_token_password
    unless client_application.allow_grant_type_password?
      return render_response(:error_description => "this application is not authorized to use grant_type password", :error => :unauthorized_application)
    end
    
    if request_param(:username).blank?
      return render_response(:error_description => "username must be provided", :error => :invalid_request)
    end
    
    if request_param(:password).nil?
      return render_response(:error_description => "password must be provided", :error => :invalid_request)
    end

#    do we need to require signature?
#    if request_param(:sig).blank?
#      return render_response(:error_description => "signature must be provided", :error => :invalid_request)
#    end

    unless valid_signature?
      return render_response(:error_description => "invalid signature", :error => :invalid_request)
    end

    user = authenticate_user(request_param(:username), request_param(:password))
    unless user
      return render_response(:error_description => "invalid username and/or password", :error => :invalid_request)
    end
    
    access_token = client_application.create_access_token(:user=>user, :scope=>scope)
    refresh_token = client_application.create_refresh_token(:user=>user, :scope=>scope)
    Platform::ApplicationUser.touch(client_application, user)
    render_response(:access_token => access_token.token, :refresh_token => refresh_token.token, :expires_in => (access_token.valid_to.to_i - Time.now.to_i))
  end

  # request token with grant_type = refresh_token
  def oauth2_request_token_refresh_token
    if request_param(:refresh_token).blank?
      return render_response(:error_description => "refresh_token must be provided", :error => :invalid_request)
    end
    
    refresher = Platform::Oauth::RefreshToken.find(:first, :conditions => ["application_id = ? and token = ? and invalidated_at is null", client_application.id, request_param(:refresh_token)])
    unless refresher
      return render_response(:error_description => "invalid refresh token", :error => :invalid_request)
    end
    
    access_token = refresher.exchange!
    refresh_token = client_application.create_refresh_token(:user=>access_token.user, :scope=>scope)
    Platform::ApplicationUser.touch(client_application, access_token.user)
    render_response(:access_token => access_token.token, :refresh_token => refresh_token.token, :expires_in => (access_token.valid_to.to_i - Time.now.to_i))
  end

  # authorize with response_type = code
  def oauth2_authorize_code
    if request.post?
      if params[:authorize] == '1'
        Platform::ApplicationUser.touch(client_application)
        code = client_application.create_request_token(:user=>Platform::Config.current_user, :callback_url=>redirect_url, :scope => scope)
        return redirect_with_response(:code => code.code, :expires_in => (code.valid_to.to_i - Time.now.to_i))
      end
      
      if client_application.auto_signin?
        return redirect_to(Platform::Config.default_url)
      end
      
      return redirect_with_response(:error => :access_denied)
    end   

    render_action("authorize")
  end

  # authorize with response_type = token
  def oauth2_authorize_token
    if request.post?
      if params[:authorize] == '1'
        Platform::ApplicationUser.touch(client_application)
        access_token = client_application.create_access_token(:user=>Platform::Config.current_user, :scope=>scope)
        return redirect_with_response(:access_token => access_token.token, :expires_in => (access_token.valid_to.to_i - Time.now.to_i))
      end

      if client_application.auto_signin?
        return redirect_to(Platform::Config.default_url)
      end

      return redirect_with_response(:error => :access_denied)
    end   

    render_action("authorize")
  end

  def redirect_url_valid?(url)
    return true if xd?
    
    if redirect_url == "#{client_application.id}://authorize"
      # make sure the user_agent is an iphone
      return true
    end
    true
  end

  # redirects require signature 
  def redirect_with_response(response_params, opts = {})
    response_params = HashWithIndifferentAccess.new(response_params)
    
    # preserve state
    response_params[:state] = request_param(:state) if request_param(:state)
    
    # more scope validation must be done
    response_params[:scope] = request_param(:scope) if request_param(:scope)

    # prepare signature
    if client_application
      payload = ""
      response_params.keys.apply(:to_s).sort.each do |key| 
        payload << "#{key}=#{CGI.escape(response_params[key.to_sym].to_s)}"
      end
      payload << client_application.secret
      response_params[:sig] = Digest::MD5.hexdigest(payload)
      # pp :before, payload, response_params[:sig]
    end
    
    # process xd popup
    if xd?
      params.merge!(response_params)
      return render(:action => :xd, :layout => false)
    end   
    
    # process normal redirect urls
    if redirect_url.blank?
      @error = response_params[:error_description]
      return render_action("authorize_failure")
    end
    
    response_query = begin
      prms = []
      response_params.keys.apply(:to_s).sort.each do |key| 
        prms << "#{key}=#{CGI.escape(response_params[key.to_sym].to_s)}"
      end
      prms.join("&")
    end
    
    #support the client_id://authorize - schema for iOS SDK
    if redirect_url == "#{client_application.key}://authorize"
      redirect_to("#{redirect_url}?#{response_query}")
    else
      redirect_uri = URI.parse(redirect_url)
      redirect_uri.path = (redirect_uri.path.blank? ? "/" : redirect_uri.path)
      redirect_uri.query = redirect_uri.query.blank? ? response_query : redirect_uri.query + "&#{response_query}"
      redirect_to(redirect_uri.to_s)
    end    
  end

  def jsonp?
    not params[:callback].blank?
  end

  def render_response(response_params, opts = {})
    response_params = HashWithIndifferentAccess.new(response_params)
    
    # preserve state
    response_params[:state] = request_param(:state) if request_param(:state)
    
    # more scope validation must be done
    response_params[:scope] = request_param(:scope) if request_param(:scope)

    # we need to support json and redirect based method as well
    if jsonp?
      render(:text => "#{params[:callback].strip}(#{response_params.to_json})")
    else  
      render(:json => response_params.to_json)
    end
  end
  
  def display
    return "mobile" if mobile_device?
    return params[:display] if params[:display]
    "web"   
  end
  
  def render_action(action)
    if display == 'web'
      render(:action => "#{action}_#{display}")
    else      
      render(:action => "#{action}_#{display}", :layout => false)
    end
  end    

end
