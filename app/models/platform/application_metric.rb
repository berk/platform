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
#-- Platform::ApplicationMetric Schema Information
#
# Table name: platform_application_metrics
#
#  id                   INTEGER         not null, primary key
#  type                 varchar(255)    
#  interval             datetime        
#  application_id       integer         
#  active_user_count    integer         
#  new_user_count       integer         
#  created_at           datetime        
#  updated_at           datetime        
#
# Indexes
#
#  pamai    (application_id, interval) 
#
#++

class Platform::ApplicationMetric < ActiveRecord::Base
  set_table_name :platform_application_metrics
  
  belongs_to :application, :class_name => "Platform::Application"
  
  def self.find_or_create(app, interval)
    metric = self.find(:first, :conditions => ["application_id = ? and 'interval' = ?", app.id, interval])
    metric || self.create(:application => app, :interval => interval, :type => self.name)
  end
  
  def self.interval_duration
    15.minutes
  end
  
  def self.calculate_metric(app, interval)
    metric = find_or_create(app, interval)
    interval_start = interval
    interval_end = interval_start + interval_duration
    
    results = execute_query("select count(distinct user_id) as count from platform_application_logs where application_id=#{app.id} and created_at >= '#{interval_start}' and created_at < '#{interval_end}'");
    metric.active_user_count = results.first["count"]

    results = execute_query("select count(distinct user_id) as count from platform_application_users where application_id=#{app.id} and created_at >= '#{interval_start}' and created_at < '#{interval_end}'");
    metric.new_user_count = results.first["count"]

    metric.save
  end
  
private

  def self.execute_query(str)
    connection.execute(str)
  end

end
