class Platform::Admin::ForumController < Platform::Admin::BaseController

  def index
    @topics = Platform::ForumTopic.filter(:params => params, :filter => Platform::ForumTopicFilter)
  end

  def messages
    @messages = Platform::ForumMessage.filter(:params => params, :filter => Platform::ForumMessageFilter)
  end
  
end
