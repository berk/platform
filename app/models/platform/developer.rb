class Platform::Developer < ActiveRecord::Base
  set_table_name :platform_developers

  belongs_to :user, :class_name => Platform::Config.user_class_name, :foreign_key => :user_id
  
  has_many :applications, :class_name => "Platform::Application"
  has_many :application_developers, :class_name => "Platform::ApplicationDeveloper"
  
  def self.for(user)
    return nil unless user and user.id 
    return nil if Platform::Config.guest_user?(user)
    return user if user.is_a?(Platform::Developer)
    find_by_user_id(user.id)
  end
  
  def self.find_or_create(user)
    dev = find(:first, :conditions => ["user_id = ?", user.id])
    dev = create(:user => user, :name => Platform::Config.user_name(user)) unless dev
    dev
  end
  
end
