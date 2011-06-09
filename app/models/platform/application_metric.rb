class Platform::ApplicationMetric < ActiveRecord::Base
  set_table_name :platform_application_metrics
  
  belongs_to :application, :class_name => "Platform::Application"
  
end
