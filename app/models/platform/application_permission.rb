class Platform::ApplicationPermission < ActiveRecord::Base
  set_table_name :platform_application_permissions
  
  belongs_to :application, :class_name => "Platform::Application"
  belongs_to :permission, :class_name => "Platform::Permission"
  
end
