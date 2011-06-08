class Platform::ForumMessage < ActiveRecord::Base
  set_table_name :platform_forum_messages

  belongs_to :user, :class_name => Platform::Config.user_class_name, :foreign_key => :user_id
  belongs_to :topic, :class_name => "Platform::ForumTopic", :foreign_key => :forum_topic_id

  def toHTML
    return "" unless message
    ERB::Util.html_escape(message).gsub("\n", "<br>")
  end

end
