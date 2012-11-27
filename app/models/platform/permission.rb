#--
# Copyright (c) 2011 Michael Berkovich
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

class Platform::Permission < ActiveRecord::Base
  set_table_name :platform_permissions

  has_many :application_permissions, :class_name => "Platform::ApplicationPermission"
  belongs_to :icon, :class_name => Platform::Config.site_media_class, :foreign_key => "icon_id"
  
  def self.find_or_create(key)
    find_by_keyword(key) || create(:keyword => key, :description => "")
  end
    
  def self.for(key)
    find_by_keyword(key)
  end
    
  def icon_url
    return Platform::Config.default_app_icon unless icon
    if Platform::Config.site_media_enabled?
      Platform::Config.icon_url(icon)  
    else
      icon.url
    end
  end
  
  def store_icon(file)
    if Platform::Config.site_media_enabled?
      update_attributes(:icon => Platform::Config.create_media(file))
    else
      self.icon = Platform::Media::Image.create
      self.icon.write(file, :size => 16)
      self.save
    end  
  end

  def self.developer_options
    find(:all, :conditions => "level = 0", :order => "position asc")
  end

  def self.admin_options
    find(:all, :order => "position asc")
  end
  
end
