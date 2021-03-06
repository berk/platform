#--
# Copyright (c) 2011 Michael Berkovich
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

module Platform
  module Api
    class BaseController < ActionController::Base
      before_filter :ensure_api_enabled 
      before_filter :set_default_format
      before_filter :authenticate
      after_filter  :log_api_call
  
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
      class InvalidTokenError < ApiError ; end
      class ResponseStructureError < ApiError ; end

      class LoginError < StandardError ; end

      PLATFORM_NON_LOGGED_EXCEPTIONS = [
        ActionController::MethodNotAllowed,
        ActionController::UnknownAction,
        ActiveRecord::RecordNotFound,
        ForbiddenError,
        MethodNotAllowedError, 
        ServiceUnavailableError,
        UnauthorizedError
      ]

      rescue_from StandardError do |e|
        pp e.message, e.backtrace
        log_exception(e) if should_log_error?(e)
        render_exception(e)
      end

    protected

      def log_exception(e)
        Platform::LoggedException.create_from_exception(self, e, nil)
      end
  
    private

      ############################################################################
      #### General Methods
      ############################################################################
      def enabled?
        Platform::Config.enable_api?
      end

      def allow_public?
        Platform::Config.api_allow_public?
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
        authenticate_via_cookie if cookies_enabled? and (not jsonp?)

        if oauth_attempted?
          raise InvalidTokenError.new('Invalid access token') if oauth_failed?
        else  
          redirect_to_login unless allow_public?
        end
      end

      def authenticate_via_oauth
        user = access_token.try(:user)
        Platform::Config.init(user) if user
      end

      # should be overloaded by the extending class
      def authenticate_via_cookie
        pp :cookies, session[:user_id]
        user = Platform::Config.user_class.find_by_id(session[:user_id])
        Platform::Config.init(user) if user
      end
  
      def access_token
        unless defined?(@access_token)
          @access_token = nil
          if access_token_header
            parts = access_token_header.split(' ')
            if parts.first == 'Bearer'
              @access_token = Platform::Application.find_token(parts.last) 
            end  
          elsif access_token_param
            @access_token = Platform::Application.find_token(access_token_param)
          end  
        end
        @access_token
      end

      def access_token_header
        @access_token_header ||= request.headers["Authorization"]
      end

      def access_token_param
        @access_token_param ||= params[:access_token] || params[:oauth_token]
      end

      def logged_in?
        not Platform::Config.current_user_is_guest?
      end

      def oauth_attempted_and_failed?
        oauth_attempted? and oauth_failed?
      end  
  
      def oauth_failed?
        access_token.nil?
      end

      def oauth_attempted?
        access_token_param or (access_token_header and access_token_header.index('Bearer'))
      end

      def current_user
        Platform::Config.current_user
      end

      ############################################################################
      #### Response Methods
      ############################################################################
      def render_response(obj, opts={})
        to_opts = params.merge(:max_models => limit, :viewer => current_user, :api_version => api_version)
        
        proc = Proc.new do |k, v| 
          if v.kind_of?(Hash)  
            v.delete_if(&proc)
            nil
          else 
            v.blank? 
          end
        end

        if obj.is_a?(ActiveRecord::Relation)
          obj = obj.collect{|c| c.to_api_hash(opts)}
        elsif obj.kind_of?(ActiveRecord::Base)
          obj = obj.to_api_hash(opts)
        end

        if obj.is_a?(Array)
          obj = obj.collect do |item|
            if item.kind_of?(ActiveRecord::Base)
              item.to_api_hash(opts).delete_if(&proc)
            else
              item
            end
          end
          obj = sanitize_results(obj, opts)
        elsif obj.is_a?(Hash)  
          obj.delete_if(&proc)
        end

        # validate_response_structure(json)

        respond_to do |format|
          format.json do
            json = obj.to_json

            if jsonp?
              script = "#{params[:callback].strip}(#{json})"
              render(:text => script)
            else  
              render(opts.merge(:json => json))
            end
          end
  
          format.xml do
            if obj.is_a?(Hash) && obj.has_key?('error')
              obj = obj['error']
              opts[:xml_root] = 'error'
            end
            render opts.merge(:text => obj.to_api_xml(to_opts.merge(:root => opts[:xml_root] || xml_root)))
          end
        end
    
        add_response_headers

        true
      end  
  
      def sanitize_results(results, opts = {})
        if results.size == 1 and not only_list?
          results = results.first
        else
          hash = {'results' => results}
          hash['page']          = page if page > 1 || limit == results.size
          hash['previous_page'] = prev_page if page > 1
          hash['next_page']     = next_page if limit == results.size
          results = hash
        end
        results
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
  
      def page_results
        model_class.where(page_model_conditions)
      end

      def order
        'id ASC'
      end
  
      def page_models
        @page_models ||= page_results.limit(limit).offset(offset).order(order).all
      end

      def page_model
        @page_model ||= page_results.first || raise(ActiveRecord::RecordNotFound)
      end
  
      def page_model_conditions(id_fields=nil)
        return nil if page_ids.empty?
        {:id => page_ids}
      end
  
      def page_ids
        @page_ids ||= begin
          id_fields ||= self.class.id_fields
          ids(id_fields)
        end
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
        ids = ids.flatten.compact.uniq.collect{|id| id.to_i}
        ids = default_model_ids if ids.empty?

        ids
      end
  
      def default_model_ids
        []
      end
    
      def success_message
        {:result => "Ok"}
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
          "api_rate_limit_u_#{current_user.id}"
        else
          "api_rate_limit_ip_#{request.ip}"
        end
      end

      def only_list?
        params[:only_list] || false
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
        url_for(params.merge(navigation_params(page - 1)))
      end

      def next_page
        url_for(params.merge(navigation_params(page + 1)))
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
      def ensure_api_enabled
        raise ServiceUnavailableError.new('API Disabled') unless enabled?
      end

      def ensure_post
        raise MethodNotAllowedError.new('POST required') unless request.post?
      end

      def ensure_get
        raise MethodNotAllowedError.new('GET required') unless request.get?
      end

      def ensure_put
        raise MethodNotAllowedError.new('PUT required') unless request.put?
      end

      def ensure_delete
        raise MethodNotAllowedError.new('DELETE required') unless request.delete?
      end

      def ensure_application
        raise LoginError.new("This API can only be called through an application") unless client_app
      end
  
      def ensure_logged_in
        raise LoginError.new("You must be logged in to use this API") unless logged_in?
      end

      def ensure_ids_provided
        raise ApiError.new("Provide an id or ids for the object") if ids.empty?
      end
      
      # should be overwritten by the implementing class - this is cutsom stuff for some apps
      def ensure_ownership(user=current_user, models=page_models)
        raise ForbiddenError.new('Permission denied') unless models.all? { |ii| ii.user == current_user }
      end
      ############################################################################  

      def split_param(name)
        params[name].to_s.split(/\s*,\s*/)
      end
  
      def redirect_to_login
        redirect_to(:controller => Platform::Config.login_url)
      end

      def log_api_call
        return unless Platform::Config.api_logging_enabled?
    
        duration = response.headers['X-Runtime']
        Platform::ApplicationLog.create(
              :application => client_app,
              :user_id => current_user.try(:id), 
              :event => "#{params[:controller]}-#{params[:action]}", 
              :data => params,
              :request_method => request.request_method,
              :user_agent => request.user_agent,
              :ip => request.remote_ip,
              :duration => (duration =~ /[.0-9]/) ? duration.to_f / 1000 : nil
        )
      end
  
      ############################################################################
      #### Exceptions
      ############################################################################

      def should_log_error?(ex)
        return true if Rails.env.development?
        not PLATFORM_NON_LOGGED_EXCEPTIONS.include?(ex.class)
      end
  
      def render_exception(ex)
        error = {
          'type'    => 'ApiException'
        }
        case ex
          when ActiveRecord::RecordNotFound
            status           = :not_found
            error['message'] = 'Not Found'
          when ActiveRecord::StatementInvalid
            status           = :bad_request
            error['message'] = 'Bad Request'
          when ApiError
            error['type']    = 'OAuthException' if ex.is_a?(UnauthorizedError)
            error['message'] = ex.message
            status           = ex.status
          else
            error['message'] = ex.message
            status           = :internal_server_error
        end
        params[:only_list] = nil
        render_response({'error' => error}, :status => status)
      end  
  
      ############################################################################
      #### Response Validation
      ############################################################################
  
      def api_version
        @api_version ||= params[:api_version] || client_app.try(:api_version) || Platform::Config.api_default_version
      end
  
      def api_reference_for_path(ref, path)
        parts = path.split("/")
        return ref[parts.first] if parts.length == 1
        return nil if ref[parts.first].nil? or ref[parts.first][:actions].nil?
        ref[parts.first][:actions][parts.last]    
      end
  
      def handle_document_structure_error(msg)
        pp msg
        log_exception(ResponseStructureError.new(msg))
      end
  
      def validate_response_structure(json)
        return unless Platform::Config.enable_api_verification?
    
        path = request.url.split(Platform::Config.api_base_url).last.split('?').first.split("-").first
    #    pp request.url, path
    
        path = 'profile' if path.blank? # make this configurable option

        hash = JSON.parse(json)
    #    pp hash
    
        ref = Platform::Config.api_reference(api_version)
        return handle_document_structure_error("Unsupported API version: #{api_version}") if ref.nil?

        ref = api_reference_for_path(ref, path)
        return handle_document_structure_error("Unsupported API path: #{path}") if ref.nil?

        fields = ref[:fields]
    #    pp fields

        undocumented_fields = []
        hash.keys.each do |key|
          if fields[key].nil?
            undocumented_fields << key
          end
        end
    
        handle_document_structure_error("Unsupported or undocumented fields for API version #{api_version}, path #{path}: #{undocumented_fields.join(', ')}") if undocumented_fields.any?        
      end
  
    end
  end
end
