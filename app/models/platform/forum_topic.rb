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
#-- Platform::ForumTopic Schema Information
#
# Table name: platform_forum_topics
#
#  id              INTEGER         not null, primary key
#  subject_type    varchar(255)    
#  subject_id      integer         
#  user_id         integer         not null
#  topic           text            not null
#  created_at      datetime        
#  updated_at      datetime        
#
# Indexes
#
#  pftu     (user_id) 
#  pftss    (subject_type, subject_id) 
#
#++

class Platform::ForumTopic < ActiveRecord::Base
  self.table_name = :platform_forum_topics

  belongs_to :user, :class_name => Platform::Config.user_class_name, :foreign_key => :user_id
  belongs_to :subject, :polymorphic => true

  def post_count
    @post_count ||= Platform::ForumMessage.count(:conditions => ["forum_topic_id = ?", self.id])
  end

  def last_post
    @last_post ||= Platform::ForumMessage.find(:first, :conditions => ["forum_topic_id = ?", self.id], :order => "created_at desc")
  end

end
