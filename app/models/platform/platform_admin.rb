# used only in the stand-alone mode
class Platform::PlatformAdmin < ActiveRecord::Base
  set_table_name :platform_admins
  
  belongs_to :user, :class_name => "Platform::PlatformUser", :foreign_key => "user_id"

end
