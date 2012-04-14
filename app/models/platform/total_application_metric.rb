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
#-- Platform::TotalApplicationMetric Schema Information
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

class Platform::TotalApplicationMetric < Platform::ApplicationMetric
  
  def self.calculate_metric(app, interval)
    metric = find_or_create(app, interval)

    results = execute_query("select count(user_id) as count from platform_application_users where application_id=#{app.id} and created_at <= '#{interval}'");
    metric.new_user_count = results.first["count"]
    metric.active_user_count = results.first["count"]

    metric.save
  end

  def user_count
    new_user_count
  end
  
end
