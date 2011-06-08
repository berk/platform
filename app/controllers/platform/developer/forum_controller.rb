class Platform::Developer::ForumController < Platform::Developer::BaseController
  
  def index
    
  end
  
  def new_message
    app = Platform::Application.find(params[:app_id])
    if params[:topic_id]
      topic = Platform::ForumTopic.find_by_id(params[:topic_id])
    else
      topic = Platform::ForumTopic.create(:subject => app, :user => Platform::Config.current_user, :topic => params[:topic])
    end
    
    Platform::ForumMessage.create(:topic => topic, :message => params[:message], :user => Platform::Config.current_user)
    redirect_to(:controller => "/platform/apps", :action => :view, :id => app.id, :sec => 'Discussions', :topic_id => topic.id, :last_page => true)
  end

  def delete_topic
    topic = Platform::ForumTopic.find_by_id(params[:topic_id])
    
    unless topic
      trfe("This topic does not exist")
      return redirect_to_source
    end  
    
    if topic.user != platform_current_user
      trfe("You cannot delete topics you didn't create.")
      return redirect_to_source
    end
    
    topic.destroy 
    trfn("The topic {topic} has been removed", nil, :topic => "\"#{topic.topic}\"")
    redirect_to_source
  end

  def delete_message
    message = Platform::ForumMessage.find_by_id(params[:message_id])
    
    unless message
      trfe("This message does not exist")
      return redirect_to_source
    end  

    if message.user != platform_current_user
      trfe("You cannot delete messages you didn't post.")
      return redirect_to_source
    end
    
    message.destroy
    trfn("The message has been removed")
    redirect_to_source
  end  

end
