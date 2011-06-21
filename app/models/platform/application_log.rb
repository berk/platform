class Platform::ApplicationLog < ActiveRecord::Base
  set_table_name :platform_application_logs

  belongs_to :user, :class_name => Platform::Config.user_class_name, :foreign_key => :user_id
  belongs_to :application, :class_name => "Platform::Application"
  
  serialize :data
  
end
