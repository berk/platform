class Platform::ForumTopic < ActiveRecord::Base
  set_table_name :platform_forum_topics

  belongs_to :user, :class_name => Platform::Config.user_class_name, :foreign_key => :user_id
  belongs_to :subject, :polymorphic => true

  def post_count
    @post_count ||= Platform::ForumMessage.count(:conditions => ["forum_topic_id = ?", self.id])
  end

  def last_post
    @last_post ||= Platform::ForumMessage.find(:first, :conditions => ["forum_topic_id = ?", self.id], :order => "created_at desc")
  end

end
