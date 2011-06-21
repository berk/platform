class Platform::Admin::AppsController < Platform::Admin::BaseController

  def index
    @apps = Platform::Application.filter(:params => params)
  end

  def view
    @app = Platform::Application.find(params[:app_id])  
  end
  
  def tokens
    @tokens = Platform::Oauth::OauthToken.filter(:params => params)
  end

  def users
    @users = Platform::ApplicationUser.filter(:params => params)
  end

  def log
    @logs = Platform::ApplicationLog.filter(:params => params)
  end

  def metrics
    @metrics = Platform::ApplicationMetric.filter(:params => params)
  end

  def permissions
    @permissions = Platform::ApplicationPermission.filter(:params => params)
  end

  def ratings
    @ratings = Platform::Rating.filter(:params => params)
  end

  def block
    app = Platform::Application.find(params[:app_id])  
    app.block!
    redirect_to(:action => :view, :app_id => app.id)
  end

  def unblock
    app = Platform::Application.find(params[:app_id])  
    app.unblock!
    redirect_to(:action => :view, :app_id => app.id)
  end

  def approve
    app = Platform::Application.find(params[:app_id])  
    app.approve!
    redirect_to(:action => :view, :app_id => app.id)
  end

  def reject
    app = Platform::Application.find(params[:app_id])  
    app.reject!
    redirect_to(:action => :view, :app_id => app.id)
  end

  def set_permission
    app = Platform::Application.find(params[:app_id])  
    app.set_permission(params[:perm], true)
    app.save
    redirect_to(:action => :view, :app_id => app.id)
  end

  def remove_permission
    app = Platform::Application.find(params[:app_id])  
    app.set_permission(params[:perm], false)
    app.save
    redirect_to(:action => :view, :app_id => app.id)
  end
  
end
