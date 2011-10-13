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

class Platform::ForumController < Platform::BaseController

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
