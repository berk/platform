class Platform::Category < ActiveRecord::Base
  set_table_name :platform_categories

  acts_as_tree :order => "position, name"
  has_many :application_categories, :class_name => "Platform::ApplicationCategory", :order => "position"
  has_many :applications, :class_name => "Platform::Application", :through => :application_categories

  def self.root
    find_by_keyword('root') || create(:keyword => 'root', :name => 'Root')
  end

  def self.category_id_by_keyword(keyword)
    cat = find_by_keyword(keyword)
    return nil if not cat
    cat.id
  end

  def root?
    keyword == 'root'  
  end
  
  def featured_application_categories
    Platform::ApplicationCategory.find(:all, :conditions => ["category_id = ? and featured = ?", self.id, true], :order => "position")
  end

  def regular_application_categories
    Platform::ApplicationCategory.find(:all, :conditions => ["category_id = ? and (featured is NULL or featured = ?)", self.id, false], :order => "position")
  end

  def full_name
    @full_name ||= begin
      names = [name]
      p = parent 
      while p do
        names << p.name
        p = p.parent
      end
      names.reverse.join(" &raquo; ")
    end
  end
end
