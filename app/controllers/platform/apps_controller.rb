class Platform::AppsController < Platform::BaseController

  def index
    unless Registry.platform.apps_directory_enabled?
      return redirect_to(:controller=>"/platform/developers/apps", :action=>"index")
    end
  
    @categories = Platform::Category.root.children
    @category = Platform::Category.find(params[:cat_id]) if params[:cat_id]
    @category = @categories.first unless @category
    
    @featured_apps = Platform::Application.featured_for_category(@category, page, 2)
    @apps = Platform::Application.for_category(@category, page, 20)
  end
  
  def view
    @app = Platform::Application.find(params[:id])
    @sections = ["Info", "Reviews", "Discussions"]
    @section = params[:sec] || "Info"
    @ratings = Platform::Rating.paginate(:conditions => ["object_type = ? and object_id = ?", @app.class.name, @app.id], 
                                          :page => page, :per_page => per_page, :order => "updated_at desc")
                                          
    params[:sec] ||= 'Info'
    if params[:sec] == 'Discussions'
      if params[:topic_id]
        @topic = Platform::ForumTopic.find_by_id(params[:topic_id])
        if params[:last_page]
          params[:page] = (@topic.post_count / per_page.to_i) 
          params[:page] += 1 unless (@topic.post_count % per_page.to_i == 0) 
          params[:page] = 1 if params[:page] == 0
        end
        @messages = Platform::ForumMessage.paginate(:all, :conditions => ["forum_topic_id = ?", @topic.id], :page => page, :per_page => per_page, :order => "created_at asc")
      else  
        @topics = Platform::ForumTopic.paginate(:all, :conditions => ["subject_type = ? and subject_id = ?", @app.class.name, @app.id], :page => page, :per_page => per_page, :order => "created_at desc")
      end
    end
  end
  
  def featured_applications_module_content
    @apps = Platform::Application.all
    render :layout => false
  end
 
  def method_missing(method, *args)
    @app = Platform::Application.find_by_canvas_name(method)
    if @app
      if @app.auto_signin?
        tokens = @app.valid_tokens_for_user(current_user)
        
        if tokens.empty?
          redirect_url = "/platform/apps/#{@app.canvas_name}"
          return redirect_to( :controller => '/platform/oauth', :action => :authorize, 
                              :response_type => :token, :client_id => @app.key, 
                              :client_secret => @app.secret, :type => :web, :redirect_url => redirect_url)
        end
        @access_token = tokens.first
      end
      
      @page_title = @app.name
    else
      @page_title = "Invalid Application"
    end
    
    @canvas_url = @app.canvas_url
    @canvas_uri = URI.parse(@app.canvas_url)
    [:controller, :action].each do |key| 
      params.delete(key)
    end

    # add all desired params here
    params[:access_token] = @access_token.token
    
    query_params = []
    params.each do |key, val|
      query_params << "#{key}=#{CGI.escape(val)}"
    end
    
    @canvas_url << "/" if @canvas_uri.path.blank?
    @canvas_url << (@canvas_uri.query.blank? ? "?" : "&")
    @canvas_url << query_params.join('&')
    
    render :action => :canvas_app 
  end
  
end
