class Platform::ApplicationMetric < ActiveRecord::Base
  set_table_name :platform_application_metrics
  
  belongs_to :application, :class_name => "Platform::Application"
  
  def self.find_or_create(app, interval)
    metric = self.find(:first, :conditions => ["application_id = ? and interval = ?", app.id, interval])
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
