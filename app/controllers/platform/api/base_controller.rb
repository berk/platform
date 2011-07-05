class Platform::Api::BaseController < ActionController::Base
  before_filter :ensure_api_enabled 
  before_filter :set_default_format
  before_filter :authenticate
  before_filter :before_api_call
  after_filter  :after_api_call
  
  class ApiError < StandardError
    def status
      @status ||= self.class.name.split('::').last.sub('Error','').underscore.to_sym
    end
    def init_cause(cause)
      @cause = cause
      self
    end
    def message
      @cause.try(:message) || super
    end
  end
  
  class BadRequestError < ApiError ; end
  class ForbiddenError < ApiError ; end
  class MethodNotAllowedError < ApiError ; end
  class ServiceUnavailableError < ApiError ; end
  class UnauthorizedError < ApiError ; end
  class JSONPError < ApiError ; end
  class LoginError < StandardError ; end
  
  include SslRequirement

protected

  def ssl_required?
    return false if client_app.nil?
    ! (Rails.env.development? || Rails.env.test?)
  end

private

  ############################################################################
  #### General Methods
  ############################################################################
  def allow_public?
    Platform::Config.enable_public_api?
  end

  def enabled?
    Platform::Config.enable_api?
  end

  def ensure_api_enabled
    raise ServiceUnavailableError.new('API Disabled') unless enabled?
  end

  def client_app
    @client_app ||= access_token.try(:application)
  end
  
  def set_default_format
    request.format = :json if params[:format].nil?
  end
  
  def all?
    params[:all].to_s.param_true?
  end

  def cookies_enabled?
    Platform::Config.api_cookies_enabled?
  end
  
  ############################################################################
  #### Authentication Methods
  ############################################################################
  def authenticate
    authenticate_via_oauth 

    if oauth_attempted? and not logged_in?
      raise Exception.new('Invalid access token')
    else
      redirect_to_login unless allow_public?
    end
  end

  # should be overloaded by the extending base class
  def authenticate_via_oauth
    user = access_token.try(:user)
    Platform::Config.init(user) if user
  end

  def access_token
    unless defined?(@access_token)
      @access_token = Platform::Application.find_token(params[:access_token])
    end

    if @access_token.nil? && access_token_param
      @access_token = Platform::Oauth::AccessToken.first(:conditions => {:token => access_token_param, :invalidated_at => nil})
    end

    @access_token
  end

  def access_token_param
    @access_token_param ||= params[:access_token] || params[:oauth_token]
  end

  def logged_in?
    not Platform::Config.current_user_is_guest?
  end

  def oauth_attempted?
    access_token_param || request.env['Authorization'] =~ /oauth/i
  end

  ############################################################################
  #### Response Methods
  ############################################################################
  def render_response(obj, opts={})
    if obj.is_a?(Array)
      hash = {'results' => obj}
      hash['page']          = page if page > 1 || limit == obj.size
      hash['previous_page'] = prev_page if page > 1
      hash['next_page']     = next_page if limit == obj.size
      obj = hash
    end

    # what is to_opts for?
    to_opts = params.merge(:max_models => limit, :viewer => Platform::Config.current_user)
    respond_to do |format|
      format.json   do
        if jsonp?
          script = "#{params[:callback].strip}(#{obj.to_json(to_opts)})"
          render(:text => script)
        else  
          render(opts.merge(:json => obj.to_json(to_opts)))
        end
      end
  
      format.xml do
        if obj.is_a?(Hash) && obj.has_key?('error')
          obj = obj['error']
          opts[:xml_root] = 'error'
        end
        render opts.merge(:text => obj.to_xml(to_opts.merge(:root => opts[:xml_root] || xml_root)))
      end
    end

    add_response_headers

    true
  end  
  
  def add_response_headers
    return unless enabled?
    return unless rate_limited?
    response.headers['X-API-Rate-Limit'] = request_limit.to_s
    response.headers['X-API-Rate-Remaining'] = (request_limit - request_count.to_i).to_s
    response.headers['X-API-Rate-Window'] = request_window.to_s
  end
  
  def max_models
    Platform::Config.api_max_models
  end
  
  def page
    (params[:page] || 1).to_i
  end

  def offset
    (params[:offset] || limit * (page - 1)).to_i
  end

  # make this configurable
  def limit
    @limit ||= begin
      lmt = params[:limit].to_i
      if 0 == lmt || (lmt > max_models && limited_models?)
        lmt = max_models
      end
      lmt
    end
  end

  def limited_models?
    not client_app.try(:allow_unlimited_models?)
  end
  
  def model_class
    raise Exception.new("must be implemented in the extanding class")
  end
  
  def page_models
    @page_models ||= model_class.all(:conditions => page_model_conditions, :limit => limit, :offset => offset, :order => 'id ASC')
  end

  def page_model
    @page_model ||= model_class.first(:conditions => page_model_conditions) || raise(ActiveRecord::RecordNotFound)
  end
  
  def page_model_conditions(id_fields=nil)
    id_fields ||= self.class.id_fields
    {:id => ids(id_fields)}
  end
  
  # default id fields
  def self.id_fields
    [:id, :ids]
  end
  
  def ids(id_fields=nil)
    id_fields ||= self.class.id_fields
    ids = []
    id_fields.each do |field|
      ids << params[field].split(',') if params[field]
    end
    ids = ids.flatten.compact.uniq.apply(:to_i)
    ids = default_model_ids if ids.empty?

    ids
  end
  
  def default_model_ids
    default_models.ids
  end

  def default_models
    raise Exception.new("must be implemented in the extanding class")
  end
  
  ############################################################################
  #### JSONP Methods
  ############################################################################
  def jsonp?
    not params[:callback].blank?
  end

  ############################################################################
  #### XML Methods
  ############################################################################
  def xml_root
    model_class.to_s.underscore.pluralize
  end
  
  ############################################################################
  #### Date/Time Methods
  ############################################################################
  def start_time
    parse_time(params[:since], '2007-01-01')
  end

  def end_time
    parse_time(params[:until], Date.tomorrow.to_s(:db))
  end

  def parse_time(string, default)
    case string
      when nil          then default
      when /today/i     then Date.today.to_s(:db)
      when /yesterday/i then Date.yesterday.to_s(:db)
      else                   Time.parse(string).to_s(:db)
    end
  end  
  
  ############################################################################
  #### Rate Limits
  ############################################################################
  def check_rate_limit
    return unless rate_limited?

    if request_count
      if request_count >= request_limit
        # Over the limit.
        raise ForbiddenError.new('Rate limit exceeded.')
      else
        # Under the limit.
        Platform::Cache.increment(cache_key)
      end
    else
      # First request in time frame.
      Platform::Cache.set(cache_key, '1', :expiry => request_window, :raw => true)
    end
  end

  def rate_limited?
    client_app.nil? || client_app.rate_limited?
  end

  def cache_key
    @cache_key ||= if logged_in?
      "api_rate_limit_u_#{Platform::Config.current_user.id}"
    else
      "api_rate_limit_ip_#{request.ip}"
    end
  end

  def request_limit
    @request_limit ||= Platform::Config.api_request_limit
  end

  def request_count
    @request_count ||= begin
      count = Platform::Cache.get(cache_key, :raw => true)
      count && count.to_i
    end
  end

  def request_window
    @request_window ||= Platform::Config.api_request_window
  end
  
  ############################################################################
  #### Navigation Params
  ############################################################################
  def prev_page
    url_for params.merge(navigation_params(page - 1))
  end

  def next_page
    url_for params.merge(navigation_params(page + 1))
  end

  def navigation_params(page)
    {
      :controller => "api/#{controller_name}",
      :action     => action_name,
      :page       => page,
      :format     => 'json' == params[:format] ? nil : params[:format]
    }
  end
  ############################################################################  
  
  ############################################################################
  #### Ensurance
  ############################################################################
  def ensure_post
    raise MethodNotAllowedError.new('POST required') unless request.post?
  end
  
  def ensure_logged_in
    raise LoginError if Platform::Config.current_user.guest?
  end
  ############################################################################  

  def split_param(name)
    params[name].to_s.split(/\s*,\s*/)
  end
  
private

  def redirect_to_login
    redirect_to("/login")
  end

  def before_api_call
    return unless Platform::Config.enable_api_log?
    @api_log = Platform::ApplicationLog.create(:application => client_app, :user_id => Platform::Config.current_user.try(:id), :event => "#{params[:controller]}-#{params[:action]}", :data => params)
  end
  
  def after_api_call
    return unless Platform::Config.enable_api_log?
    @api_log.update_attributes(:user_id => Platform::Config.current_user.try(:id)) if @api_log    
  end
end
