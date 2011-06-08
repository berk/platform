class Platform::ApplicationUser < ActiveRecord::Base
  set_table_name :platform_application_users

  belongs_to :user, :class_name => Platform::Config.user_class_name, :foreign_key => :user_id
  belongs_to :application, :class_name => "Platform::Application"

  def self.for(app, user=Platform::Config.current_user)
    # cache this method
    find(:first, :conditions => ["application_id = ? and user_id = ?", app.id, user.id])
  end
  
  def self.find_or_create(app, user=Platform::Config.current_user)
    self.for(app, user) || create(:application => app, :user => user)
  end

  def self.touch(app, user=Platform::Config.current_user)
    find_or_create(app, user).touch
  end

end
