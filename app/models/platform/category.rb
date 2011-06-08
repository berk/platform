class Platform::Category < ActiveRecord::Base
  set_table_name :platform_categories

  acts_as_tree :order => "position, name"
  has_many :category_items, :class_name => "Platform::CategoryItem", :order => "position"

  def self.root
    find_by_keyword('root') || create(:keyword => 'root', :name => 'Root')
  end

end
