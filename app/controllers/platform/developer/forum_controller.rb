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

class Platform::Developer::ForumController < Platform::Developer::BaseController
  
  def index
    @topics = Platform::ForumTopic.where("subject_id is null").order("created_at desc").page(page).per(per_page)
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

      @messages = Platform::ForumMessage.where("forum_topic_id = ?", @topic.id).order("created_at asc").page(page).per(per_page)
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
