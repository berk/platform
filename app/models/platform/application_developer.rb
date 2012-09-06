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
#-- Platform::ApplicationDeveloper Schema Information
#
# Table name: platform_application_developers
#
#  id                INTEGER     not null, primary key
#  application_id    integer     
#  developer_id      integer     
#  created_at        datetime    
#  updated_at        datetime    
#
# Indexes
#
#  index_platform_application_developers_on_developer_id      (developer_id) 
#  index_platform_application_developers_on_application_id    (application_id) 
#
#++

class Platform::ApplicationDeveloper < ActiveRecord::Base
  self.table_name = :platform_application_developers

  belongs_to :developer, :class_name => "Platform::Developer"
  belongs_to :application, :class_name => "Platform::Application"
  
end
