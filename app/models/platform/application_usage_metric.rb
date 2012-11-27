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

class Platform::ApplicationUsageMetric < ActiveRecord::Base
  set_table_name :platform_application_usage_metrics
  
  belongs_to :application, :class_name => "Platform::Application"
  
  def self.find_or_create(app, interval, event)
    metric = find(:first, :conditions => ["application_id = ? and interval = ? and event = ?", app.id, interval, event])
    metric || create(:application => app, :interval => interval, :event => event)
  end
  
  def self.interval_duration
    15.minutes
  end
  
  def self.calculate_metric(app, interval)
    interval_start = interval
    interval_end = interval_start + interval_duration
    
    results = execute_query("select event, count(event) as count, avg(duration) as avg_response_time from platform_application_logs where application_id=#{app.id} and created_at >= '#{interval_start}' and created_at < '#{interval_end}' group by event");
    results.each do |result|
      metric = find_or_create(app, interval, result['event'])
      metric.count = result['count']
      metric.avg_response_time = result['avg_response_time']
      metric.error_count = 0 # need to add ability to count errors
      metric.save
    end
  end
  
private

  def self.execute_query(str)
    connection.execute(str)
  end
  
end
