class Platform::DeveloperRole < ActiveRecord::Base
  self.table_name = :platform_developer_roles

  belongs_to :developer, :class_name => "Platform::Developer"
  belongs_to :role, :class_name => "Platform::Role"
end
