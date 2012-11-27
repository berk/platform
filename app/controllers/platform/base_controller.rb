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

class Platform::BaseController < ApplicationController

  skip_filter :redirect_if_not_logged_in

  before_filter :init_platform
  before_filter :validate_platform_enabled
  before_filter :validate_guest_user

  if Platform::Config.before_filters.any?
    before_filter *Platform::Config.before_filters
  end
  
  if Platform::Config.skip_before_filters.any?
    skip_before_filter *Platform::Config.skip_before_filters
  end
  
  if Platform::Config.after_filters.any?    
    after_filter *Platform::Config.after_filters
  end

  layout Platform::Config.site_layout

  helper :platform
  
  if Platform::Config.helpers.any?
    helper *Platform::Config.helpers 
  end

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
  
  def mobile_device?
    return false if request.user_agent.blank?
    ua = request.user_agent.downcase
    ['iphone', 'android'].any? {|agent| ua.index(agent)}
  end
  helper_method :mobile_device?
  
private

  def init_platform
    site_current_user = nil
    begin
      site_current_user = eval(Platform::Config.current_user_method)
      site_current_user = nil if site_current_user.class.name != Platform::Config.user_class_name
    rescue Exception => ex
      raise Platform::Exception.new("Platform cannot be initialized because #{Platform::Config.current_user_method} failed with: #{ex.message}")
    end
    
    # initialize request thread variables
    Platform::Config.init(site_current_user)
  end
  
  def redirect_to_source(default_url = nil)
    return redirect_to(params[:source_url]) unless params[:source_url].blank?
    return redirect_to(request.env['HTTP_REFERER']) unless request.env['HTTP_REFERER'].blank?
    return redirect_to(default_url) if default_url
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
  
end