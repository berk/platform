class Platform::Developer::ForumController < Platform::Developer::BaseController
  
  def index
    @topics = Platform::ForumTopic.paginate(:all, :conditions => ["subject_id is null"], :page => page, :per_page => per_page, :order => "created_at desc")
  end

  def topic
    if request.post?
      if params[:topic_id]
        topic = Platform::ForumTopic.find_by_id(params[:topic_id])
      else
        topic = Platform::ForumTopic.create(:user => platform_current_user, :topic => params[:topic])
      end
      
      Platform::ForumMessage.create(:topic => topic, :message => params[:message], :user => platform_current_user)
      return redirect_to(:action => :topic, :topic_id => topic.id, :last_page => true)
    end
    
    unless params[:mode] == "create"
      @topic = Platform::ForumTopic.find_by_id(params[:topic_id])
      if params[:last_page]
        params[:page] = (@topic.post_count / per_page.to_i) 
        params[:page] += 1 unless (@topic.post_count % per_page.to_i == 0)
        params[:page] = 1 if params[:page] == 0
      end

      @messages = Platform::ForumMessage.paginate(:all, :conditions => ["forum_topic_id = ?", @topic.id], :page => page, :per_page => per_page, :order => "created_at asc")
    end
  end

  def delete_topic
    topic = Platform::ForumTopic.find_by_id(params[:topic_id])
    
    if topic.user != platform_current_user
      trfe("You cannot delete topics you didn't create.")
      return redirect_to(:action => :index)
    end
    
    topic.destroy if topic
    trfn("The topic {topic} has been removed", 'Developer Forum', :topic => "\"#{topic.topic}\"")
    redirect_to(:action => :index)
  end

  def delete_message
    message = Platform::ForumMessage.find_by_id(params[:message_id])
    
    unless message
      trfe("This message does not exist")
      return redirect_to(:action => :index)
    end  

    if message.user != platform_current_user
      trfe("You cannot delete messages you didn't post.")
      redirect_to(:action => :topic, :topic_id => message.language_forum_topic.id)
    end
    
    message.destroy
    trfn("The message has been removed")
    redirect_to(:action => :topic, :topic_id => message.topic.id)
  end  
  
end
