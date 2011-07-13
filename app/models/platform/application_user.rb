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

class Platform::ApplicationUser < ActiveRecord::Base
  set_table_name :platform_application_users

  belongs_to :user, :class_name => Platform::Config.user_class_name, :foreign_key => :user_id
  belongs_to :application, :class_name => "Platform::Application"

  serialize :data

  def self.for(app, user=Platform::Config.current_user)
    # cache this method
    find(:first, :conditions => ["application_id = ? and user_id = ?", app.id, user.id])
  end
  
  def self.find_or_create(app, user=Platform::Config.current_user)
    self.for(app, user) || create(:application => app, :user => user)
  end

  def self.touch(app, user=Platform::Config.current_user)
    find_or_create(app, user).touch
  end

end
