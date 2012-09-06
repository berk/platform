#--
# Copyright (c) 2010-2012 Michael Berkovich
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
#
#-- Platform::Category Schema Information
#
# Table name: platform_categories
#
#  id            INTEGER         not null, primary key
#  type          varchar(255)    
#  name          varchar(255)    
#  keyword       varchar(255)    
#  position      integer         
#  enable_on     date            
#  disable_on    date            
#  parent_id     integer         
#  created_at    datetime        
#  updated_at    datetime        
#
# Indexes
#
#  index_platform_categories_on_parent_id    (parent_id) 
#
#++

class Platform::Category < ActiveRecord::Base
  self.table_name = :platform_categories

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
