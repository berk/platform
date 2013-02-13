class Platform::Role < ActiveRecord::Base
  self.table_name = :platform_roles

  def self.init_defaults!
    [ "Administrator", 
      "Developer", "Graphic Designer", "Project Manager", 
      "QA Engineer", "Financial Analyst", "Marketing Manager", 
      "Translator", "Legal Advisor"].each do |name|
        create(:name => name)
      end
  end

end
