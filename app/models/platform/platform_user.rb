#--
# Copyright (c) 2011 Michael Berkovich, Geni Inc
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

# used only in the stand-alone mode
class Platform::PlatformUser < ActiveRecord::Base
  set_table_name :platform_users
  
  has_one :admin, :class_name => "Platform::PlatformAdmin", :foreign_key => "user_id", :dependent => :destroy
  
  def guest?
    id.blank?
  end
  
  def admin?
    not admin.nil? 
  end
  
  def gender
    super || 'unknown'
  end
  
  def make_admin!
    return if admin?
    
    Platform::PlatformAdmin.create(:user => self, :level => 0)
  end
  
  def to_s
    name
  end  
  
end
