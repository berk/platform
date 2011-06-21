class Platform::Admin::ForumController < Platform::Admin::BaseController

  def index
    @topics = Platform::ForumTopic.filter(:params => params)
  end

  def messages
    @messages = Platform::ForumMessage.filter(:params => params)
  end
  
end
