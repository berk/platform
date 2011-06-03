class Platform::AppsController < Platform::BaseController
  before_filter :redirect_if_not_logged_in
  skip_before_filter :init_page_profile

  def index
    unless Registry.platform.apps_directory_enabled?
      return redirect_to(:controller=>"/platform/developers/apps", :action=>"index")
    end
  
    @apps = Platform::Application.all
    @featured_apps = @apps[0..2]
    @categories = ["All Apps", "On Geni", "External Websites", "Desktop", "Mobile"]
    @category = params[:cat] || "All Apps"
  end
  
  def view
    @app = Platform::Application.find(params[:id])
    @sections = ["Info", "Discussions", "Reviews"]
    @section = params[:sec] || "Info"
  end
  
  def featured_applications_module_content
    @apps = Platform::Application.all
    render :layout => false
  end
 
  def method_missing(method, *args)
    @app = Platform::Application.find_by_canvas_name(method)
    if @app
      @page_title = @app.name
    else
      @page_title = "Invalid Application"
    end
    render :action => :canvas_app 
  end
  
end
