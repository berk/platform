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
