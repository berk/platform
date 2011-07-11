class Platform::Developer::InfoController < Platform::Developer::BaseController

  def index
    
  end
  
  def update_section
    unless request.post?
      return render(:partial => params[:section], :locals => {:mode => params[:mode].to_sym})
    end
    
    platform_current_developer.update_attributes(params[:developer])
    
    platform_current_developer.reload
    render(:partial => params[:section], :locals => {:mode => :view})
  end
  
end
