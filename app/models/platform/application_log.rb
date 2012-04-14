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
#-- Platform::ApplicationLog Schema Information
#
# Table name: platform_application_logs
#
#  id                INTEGER         not null, primary key
#  application_id    integer         
#  user_id           integer         
#  event             varchar(255)    
#  controller        varchar(255)    
#  action            varchar(255)    
#  request_method    varchar(255)    
#  data              text            
#  user_agent        varchar(255)    
#  duration          integer         
#  host              varchar(255)    
#  country           varchar(255)    
#  ip                varchar(255)    
#  created_at        datetime        
#  updated_at        datetime        
#
# Indexes
#
#  index_platform_application_logs_on_application_id_and_created_at    (application_id, created_at) 
#
#++

class Platform::ApplicationLog < ActiveRecord::Base
  set_table_name :platform_application_logs

  belongs_to :user, :class_name => Platform::Config.user_class_name, :foreign_key => :user_id
  belongs_to :application, :class_name => "Platform::Application"
  
  serialize :data
  
end
