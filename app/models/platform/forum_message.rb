#--
# Copyright (c) 2010-2012 Michael Berkovich
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
#
#-- Platform::ForumMessage Schema Information
#
# Table name: platform_forum_messages
#
#  id                INTEGER     not null, primary key
#  forum_topic_id    integer     not null
#  user_id           integer     not null
#  message           text        not null
#  created_at        datetime    
#  updated_at        datetime    
#
# Indexes
#
#  index_platform_forum_messages_on_user_id           (user_id) 
#  index_platform_forum_messages_on_forum_topic_id    (forum_topic_id) 
#
#++

class Platform::ForumMessage < ActiveRecord::Base
  self.table_name = :platform_forum_messages

  belongs_to :user, :class_name => Platform::Config.user_class_name, :foreign_key => :user_id
  belongs_to :topic, :class_name => "Platform::ForumTopic", :foreign_key => :forum_topic_id

  def toHTML
    return "" unless message
    ERB::Util.html_escape(message).gsub("\n", "<br>")
  end

end
