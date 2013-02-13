class Platform::DeveloperActivity < ActiveRecord::Base
  self.table_name = :platform_developer_activities

  belongs_to :developer, :class_name => "Platform::Developer"
end
