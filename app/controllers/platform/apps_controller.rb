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

class Platform::AppsController < Platform::BaseController

  def index
    unless Platform::Config.enable_app_directory?
      return redirect_to(:controller=>"/platform/developer/apps", :action=>"index")
    end
  
    @categories = Platform::Category.root.children
    @category = Platform::Category.find(params[:cat_id]) if params[:cat_id]
    @category = @categories.first unless @category
  
    @featured_apps = []
    @apps = []
    @search_apps = []
    
    if params[:search].blank?
      @featured_apps = Platform::Application.featured_for_category(@category, page, Platform::Config.featured_apps_per_page)
      @apps = Platform::Application.regular_for_category(@category, page, Platform::Config.suggested_apps_per_page)
    else
      @category = nil
      conditions = []
      @search_apps = Platform::Application.where("name like ? or description like ?", "%#{params[:search]}%", "%#{params[:search]}%").page(page).per(Platform::Config.searched_apps_per_page).order("name asc")
    end
  end
  
  def view
    @app = Platform::Application.find(params[:id])
    @sections = ["Info", "Reviews", "Discussions"]
    @section = params[:sec] || "Info"
    @ratings = Platform::Rating.where("object_type = ? and object_id = ?", @app.class.name, @app.id).order("updated_at desc").page(page).per(per_page)
                                          
    params[:sec] ||= 'Info'
    if params[:sec] == 'Discussions'
      if params[:topic_id]
        @topic = Platform::ForumTopic.find_by_id(params[:topic_id])
        if params[:last_page]
          params[:page] = (@topic.post_count / per_page.to_i) 
          params[:page] += 1 unless (@topic.post_count % per_page.to_i == 0) 
          params[:page] = 1 if params[:page] == 0
        end
        @messages = Platform::ForumMessage.where("forum_topic_id = ?", @topic.id).order("created_at asc").page(page).per(per_page)
      else  
        @topics = Platform::ForumTopic.where("subject_type = ? and subject_id = ?", @app.class.name, @app.id).order("created_at asc").page(page).per(per_page)
      end
    end
  end
  
  def paginate_module
    if params[:module] == 'featured_apps'  
      category = Platform::Category.find(params[:cat_id])
      apps = Platform::Application.featured_for_category(category, page, Platform::Config.featured_apps_per_page)
      render(:partial => 'featured_apps_module', :locals => {:apps => apps, :per_row => Platform::Config.featured_apps_per_row})
    elsif params[:module] == 'suggested_apps'   
      category = Platform::Category.find(params[:cat_id])
      apps = Platform::Application.regular_for_category(category, page, Platform::Config.suggested_apps_per_page)
      render(:partial => 'apps_module', :locals => {:apps => apps, :per_row => Platform::Config.suggested_apps_per_row})
    else
      conditions = ["name like ? or description like ?", "%#{params[:search]}%", "%#{params[:search]}%"]
      apps = Platform::Application.where(conditions).page(page).per(Platform::Config.searched_apps_per_page).order("name asc")
      render(:partial => 'search_apps_module', :locals => {:apps => apps})      
    end
  end
  
  def featured_applications_module_content
    @apps = Platform::Application.all
    render :layout => false
  end
 
  def xd
    render :layout => false
  end
  
  def settings
    @app_users = Platform::ApplicationUser.where("user_id = ?", current_user.id).order("updated_at desc")
  end
  
  def remove
    if request.post?
      app_user = Platform::ApplicationUser.find_by_id(params[:app_user_id])
      if app_user
        app_user.destroy 
        trfn("{app} has been removed from your account and will no longer have access to your account information.", "", :app => app_user.application.name)
      end
    end
    
    redirect_to :action => :settings  
  end
  
  def run
    @app = Platform::Application.find_by_canvas_name(params[:canvas_name])
    return render(:action => :canvas_app) unless @app
    
    @page_title = @app.name
    
    if @app.auto_signin?
      app_user = Platform::ApplicationUser.for(@app)
      
      unless app_user
        @canvas_url = "http://#{Platform::Config.site_base_url}/platform/oauth/authorize?response_type=token&client_id=#{@app.key}&display=iframe&redirect_url=#{CGI.escape(@app.canvas_url)}"
        return render(:action => :canvas_app)
      end

      tokens = @app.valid_tokens_for_user(Platform::Config.current_user)
      if tokens
        access_token = tokens.first
      else  
        access_token = client_application.create_access_token(:user=>Platform::Config.current_user)
      end
      @access_token = access_token
    end
    

    @canvas_url = @app.canvas_url
    canvas_uri = URI.parse(@app.canvas_url)
    [:controller, :action].each do |key| 
      params.delete(key)
    end

    # add all desired params here
    params[:access_token] = @access_token.token if @access_token
    params[:t] = Time.now.to_s
    
    query_params = []
    params.each do |key, val|
      query_params << "#{key}=#{CGI.escape(val)}"
    end
    
    @canvas_url << "/" if canvas_uri.path.blank?
    @canvas_url << (canvas_uri.query.blank? ? "?" : "&")
    @canvas_url << query_params.join('&')
    
    render :action => :canvas_app 
  end
  
end
