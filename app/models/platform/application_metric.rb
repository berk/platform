class Platform::ApplicationMetric < ActiveRecord::Base
  set_table_name :platform_developers
  
  belongs_to :application, :class_name => "Platform::Application"
  
end
