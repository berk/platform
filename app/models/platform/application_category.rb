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
#-- Platform::ApplicationCategory Schema Information
#
# Table name: platform_application_categories
#
#  id                INTEGER     not null, primary key
#  category_id       integer     not null
#  application_id    integer     not null
#  position          integer     
#  featured          boolean     
#  created_at        datetime    
#  updated_at        datetime    
#
# Indexes
#
#  pacca    (category_id, application_id) 
#  pacc     (category_id) 
#
#++

class Platform::ApplicationCategory < ActiveRecord::Base
  self.table_name = :platform_application_categories

  belongs_to :category, :class_name => "Platform::Category"
  belongs_to :application, :class_name => "Platform::Application"
  
  def self.find_or_create(app, cat)
    find_by_application_id_and_category_id(app.id, cat.id) || create(:application => app, :category => cat)
  end
  
end
