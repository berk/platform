# used only in the stand-alone mode
class Platform::PlatformUser < ActiveRecord::Base
  set_table_name :platform_users
  
  has_one :admin, :class_name => "Platform::PlatformAdmin", :foreign_key => "user_id", :dependent => :destroy
  
  def guest?
    id.blank?
  end
  
  def admin?
    not admin.nil? 
  end
  
  def gender
    super || 'unknown'
  end
  
  def make_admin!
    return if admin?
    
    Platform::PlatformAdmin.create(:user => self, :level => 0)
  end
  
  def to_s
    name
  end  
  
end
