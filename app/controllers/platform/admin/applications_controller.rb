class Platform::Admin::ApplicationsController < Platform::Admin::BaseController

  def index
    @apps = ClientApplication.filter(:params => params)
  end

  def view
    @app = ClientApplication.find(params[:app_id])  
  end
  
  def tokens
    @tokens = AccessToken.filter(:params => params, :filter => AccessTokenFilter)
  end

  def enable_app
    app = ClientApplication.find(params[:app_id])  
    app.enable!
    redirect_to(:action => :view, :app_id => app.id)
  end

  def disable_app
    app = ClientApplication.find(params[:app_id])  
    app.disable!
    redirect_to(:action => :view, :app_id => app.id)
  end

  def set_permission
    app = ClientApplication.find(params[:app_id])  
    app.set_permission(params[:perm], true)
    app.save
    redirect_to(:action => :view, :app_id => app.id)
  end

  def remove_permission
    app = ClientApplication.find(params[:app_id])  
    app.set_permission(params[:perm], false)
    app.save
    redirect_to(:action => :view, :app_id => app.id)
  end
  
end
