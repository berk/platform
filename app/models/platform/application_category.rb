class Platform::ApplicationCategory < ActiveRecord::Base
  set_table_name :platform_application_categories

  belongs_to :category, :class_name => "Platform::Category"
  belongs_to :application, :class_name => "Platform::Application"
  
  def self.find_or_create(app, cat)
    find_by_application_id_and_category_id(app.id, cat.id) || create(:application => app, :category => cat)
  end
  
end
