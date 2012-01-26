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

class Platform::Developer::AppsController < Platform::Developer::BaseController

  before_filter :validate_application_developer, :except => [:index, :new, :create, :version]

  def index
    @app = Platform::Application.find_by_id(params[:id]) if params[:id]
    @app = nil unless @app and @app.developed_by?(Platform::Config.current_developer)

    @apps = Platform::Application.find(:all, :conditions => ["developer_id=? and parent_id is null", Platform::Config.current_developer.id], :order => "updated_at desc")
    unless @app
      @app = @apps.first if @apps.any?
    end  

    @menu_app = @app
    @menu_app = @app.parent if @app && @app.parent

    @page_title = tr('Application Details for {app_name}', 'Client application controller title', :app_name => @app.name) if @app
  end

  def new
    @page_title = tr('Register New Application', 'Client application controller title')
    
    application
    prepare_form
  end

  def create
    if application.save
      application.store_icon(params[:new_icon]) unless params[:new_icon].blank?
      application.store_logo(params[:new_logo]) unless params[:new_logo].blank?
      
      trfn('{app_name} registered', 'Client application controller notice', :app_name => application.name)
      redirect_to(:action => :index, :id => application.id)
    else
      flash[:error] = application.errors.full_messages.join(', ')
      prepare_form
      render :action => :new
    end
  end

  def edit
    @page_title = tr('Edit {app_name}', 'Client application controller title', :app_name => application.name)
    application.touch
    @languages = Tr8n::Language.locale_options
  end

  def create_version
    @page_title = tr('Version {app_name}', 'Client application controller title', :app_name => application.name)
    @current_app = Platform::Application.find(params[:id]) 
    @app = Platform::Application.new(@current_app.attributes)
    @languages = Tr8n::Language.locale_options
  end

  def version
    old_app = Platform::Application.find(params[:current_version_id])
    
    app = Platform::Application.create(params[:application].merge(:developer => Platform::Config.current_developer))
    if params[:new_icon].blank?
      app.update_attributes(:icon_id => old_app.icon_id)
    else
      app.store_icon(params[:new_icon])
    end

    if params[:new_logo].blank?
      app.update_attributes(:logo_id => old_app.logo_id)
    else
      app.store_logo(params[:new_logo])
    end

    old_app.children.each do |child_app|
      child_app.update_attributes(:parent_id => app.id)
    end
    
    old_app.update_attributes(:parent_id => app.id, :version => (old_app.version || 1.0))

    redirect_to(:action => :index, :id => app.id)
  end

  def update
    if application.update_attributes(params[:application])
      application.store_icon(params[:new_icon]) unless params[:new_icon].blank?
      application.store_logo(params[:new_logo]) unless params[:new_logo].blank?
      
      application.application_permissions.each do |ap|
        ap.destroy
      end
      
      params[:permissions].split(",").each do |keyword|
        application.add_permission(keyword)
      end  
      
      trfn('{app_name} updated.', 'Client applicaiton controller notice', :app_name => application.name)
      redirect_to(:action => :index, :id => application.id)
    else
      flash[:error] = application.errors.full_messages.join(', ')
      prepare_form
      render :action => :edit
    end
  end

  def delete
    application.destroy
    trfn('{app_name} has been removed.', 'Client application controller notice', :app_name => application.name)
    redirect_to :action => :index
  end

  def reset_secret
    application.reset_secret!
    trfn('Secret for {app_name} has been reset.', 'Client application controller notice', :app_name => application.name)
    redirect_to :action => :index, :id => application.id 
  end

  def submit
    application.state ||= "new"
    application.submit!
    redirect_to :action => :index, :id => application.id 
  end

  def lb_permissions
    @options = Platform::Permission.developer_options
    @permissions = application.permissions
    render :layout => false
  end
  
private

  def validate_application_developer
    return unless application.id
    
    unless application.developed_by?(Platform::Config.current_developer)
      trfe("You are not authorized to access this application")
      redirect_to(:action => :index)
    end
  end

  def application
    @app ||= begin
      if params.has_key?(:id)
        Platform::Application.find(params[:id])
      elsif params.has_key?(:application)
        Platform::Application.create(params[:application].merge(:developer => Platform::Config.current_developer))
      else
        Platform::Application.new(:contact_email => Platform::Config.user_email(Platform::Config.current_user), :version => "1.0")
      end 
    end
  end
  
  def prepare_form
    @languages = Tr8n::Language.locale_options
  end
  
end
