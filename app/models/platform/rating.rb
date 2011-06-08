class Platform::Rating < ActiveRecord::Base
  set_table_name :platform_ratings

  belongs_to :user, :class_name => Platform::Config.user_class_name, :foreign_key => :user_id
  belongs_to :object, :polymorphic => true

  def self.for(app, user=Platform::Config.current_user)
    find(:first, :conditions => ["object_type = ? and object_id = ? and user_id = ?", app.class.name, app.id, user.id])
  end
  
  def self.find_or_create(app, user=Platform::Config.current_user)
    self.for(app, user) || create(:object => app, :user => user)
  end
  
  def toHTML
    return "" unless comment
    ERB::Util.html_escape(comment).gsub("\n", "<br>")
  end
  
end
