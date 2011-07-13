class Platform::Developer::AppsController < Platform::Developer::BaseController

  def index
    @app = Platform::Application.find(params[:id]) if params[:id]
    @apps = Platform::Application.find(:all, :conditions => ["developer_id=?", Platform::Config.current_developer.id], :order => "name asc")
    unless @app
      @app = @apps.first if @apps.any?
    end  
    
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
    @languages = Tr8n::Language.locale_options
  end

  def update
    if application.update_attributes(params[:application])
      application.store_icon(params[:new_icon]) unless params[:new_icon].blank?
      application.store_logo(params[:new_logo]) unless params[:new_logo].blank?
      
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

private

  def application
    @app ||= begin
      if params.has_key?(:id)
        Platform::Application.find(params[:id])
      elsif params.has_key?(:application)
        Platform::Application.create(params[:application].merge(:developer => Platform::Config.current_developer))
      else
        Platform::Application.new(:contact_email => Platform::Config.user_email(Platform::Config.current_user))
      end 
    end
  end
  
  def prepare_form
    @languages = Tr8n::Language.locale_options
  end
  
end
