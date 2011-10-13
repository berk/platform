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

class Platform::Developer::DashboardController < Platform::Developer::BaseController
  before_filter :prepare_apps, :only => [:settings, :update_section]
  
  def index
    selected_app_ids = session[:platform_dashboard_apps] || []
    if selected_app_ids.empty?
      @apps = Platform::Application.find(:all, :conditions => ["developer_id = ? and parent_id is null", platform_current_developer.id], :order => "created_at desc", :limit => 5)
      session[:platform_dashboard_apps] = @apps.collect{|app| app.id}
    else
      @apps = Platform::Application.find(:all, :conditions => ["id in (?) and developer_id = ?", selected_app_ids, platform_current_developer.id], :order => "created_at desc")
    end
  end
  
  def settings
    
  end
  
  def update_section
    unless request.post?
      return render(:partial => params[:section], :locals => {:mode => params[:mode].to_sym})
    end
    
    @selected_app_ids = params.keys - ['action', 'controller', 'section']
    session[:platform_dashboard_apps] = @selected_app_ids

#   persist in the database    
#    platform_current_developer.update_attributes(params[:developer])
#    platform_current_developer.reload

    render(:partial => params[:section], :locals => {:mode => :view})
  end

private

  def prepare_apps
    @selected_app_ids = session[:platform_dashboard_apps] || []
    @apps = Platform::Application.find(:all, :conditions => ["developer_id = ? and parent_id is null", platform_current_developer.id], :order => "created_at desc")
  end
  
end
