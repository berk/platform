class Platform::CategoryItem < ActiveRecord::Base
  set_table_name :platform_category_items

  belongs_to :category, :class_name => "Platform::Category"
  belongs_to :item, :polymorphic => true
  
end
