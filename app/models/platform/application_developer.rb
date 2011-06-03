class Platform::ApplicationDeveloper < ActiveRecord::Base
  set_table_name :platform_application_developers

  belongs_to :developer, :class_name => "Platform::Developer"
  belongs_to :application, :class_name => "Platform::Application"
  
end
