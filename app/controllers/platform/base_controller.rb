class Platform::BaseController < ApplicationController

  if Platform::Config.helpers.any?
    helper *Platform::Config.helpers
  end

  if Platform::Config.skip_before_filters.any?
    skip_before_filter *Platform::Config.skip_before_filters
  end

  if Platform::Config.before_filters.any?
    before_filter *Platform::Config.before_filters
  end
  
  if Platform::Config.after_filters.any?
    after_filter *Platform::Config.after_filters
  end
  
  before_filter :init_platform
  before_filter :validate_platform_enabled
  before_filter :validate_guest_user
  
  layout Platform::Config.site_layout

  def platform_current_user
    Platform::Config.current_user
  end
  helper_method :platform_current_user

  def platform_current_developer
    Platform::Config.current_developer
  end
  helper_method :platform_current_developer
  
  def platform_current_user_is_admin?
    Platform::Config.current_user_is_admin?
  end
  helper_method :platform_current_user_is_admin?

  def platform_current_user_is_guest?
    Platform::Config.current_user_is_guest?
  end
  helper_method :platform_current_user_is_guest?

  def platform_current_user_is_developer?
    Platform::Config.current_user_is_developer?
  end
  helper_method :platform_current_user_is_developer?
  
private

  def init_platform
    site_current_user = nil
    if Platform::Config.site_user_info_enabled?
      begin
        site_current_user = eval(Platform::Config.current_user_method)
        site_current_user = nil if site_current_user.class.name != Platform::Config.user_class_name
      rescue Exception => ex
        raise Platform::Exception.new("Platform cannot be initialized because #{Platform::Config.current_user_method} failed with: #{ex.message}")
      end
    else
      site_current_user = Platform::Developer.find_by_id(session[:platform_developer_id]) if session[:platform_developer_id]
      site_current_user = Platform::Developer.new unless site_current_user
    end
    
    # initialize request thread variables
    Platform::Config.init(site_current_user)
  end
  
  def redirect_to_source
    return redirect_to(params[:source_url]) unless params[:source_url].blank?
    return redirect_to(request.env['HTTP_REFERER']) unless request.env['HTTP_REFERER'].blank?
    redirect_to_site_default_url
  end

  def redirect_to_site_default_url
    redirect_to(Platform::Config.default_url)
  end

  def page
    params[:page] || 1
  end
  
  def per_page
    params[:per_page] || 30
  end

  # handle disabled state for Platform
  def validate_platform_enabled
    if Platform::Config.disabled?
      trfe("You don't have rights to access that section.")
      return redirect_to_site_default_url
    end
  end

  # guest users can still switch between languages outside of the site
  def validate_guest_user
    if platform_current_user_is_guest?
      trfe("You must be a registered user in order to access this section of the site.")
      return redirect_to_site_default_url
    end
  end

  # make sure that the current user is a translator
  def validate_current_developer
    unless platform_current_user_is_developer?
      return redirect_to("/platform/developers/registration")
    end
  end

  def validate_admin
    unless platform_current_user_is_admin?
      trfe("You must be an admin in order to view this section of the site")
      return redirect_to_site_default_url
    end
  end
  
end