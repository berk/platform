namespace :platform do
  
  desc "Initializes all of the tables with default data"
  task :init => :environment do
    raise "This action is prohibited in this environment" if ['production', 'stage', 'staging'].include?(Rails.env) and env('force') != 'true'
    Platform::Config.reset_all!
  end
  
  task :rollup_metrics => :environment do
    # for debugging purposes
#    Platform::RollupLog.delete_all
#    Platform::ApplicationMetric.delete_all
#    Platform::ApplicationUsageMetric.delete_all
    
    # when we bootstrap the process, we should havesome set date/time from where to start
    default_start_time = Time.parse("06/20/2011 12:00:00")
    
    if Platform::RollupLog.first == nil
      # running the rollup for the first time
      interval = interval_time_for(default_start_time)
    else
      last_rollup = Platform::RollupLog.last
      interval = interval_time_for(last_rollup.interval - 15.min) # always do the last interval and the current interval
    end
    
    rollup_interval(interval)
  end

  task :rollup_daily_metrics => :environment do
    start_date = ENV['since'] || Date.today.to_s
    start_date = Date.parse(start_date)
    end_date = Date.today
    
    while start_date <= end_date do
      log_msg("Rolling up daily metrics for #{start_date}...")
      
      Platform::Application.all.each do |app|
        Platform::DailyApplicationMetric.calculate_metric(app, start_date - 1.day)
        Platform::WeeklyApplicationMetric.calculate_metric(app, start_date - 1.week)
        Platform::MonthlyApplicationMetric.calculate_metric(app, start_date - 1.month)
        Platform::TotalApplicationMetric.calculate_metric(app, start_date)
      end
      
      start_date += 1.day
    end
    
    log_msg("Done.")
  end

private  
  
  def rollup_interval(interval)
    interval_start = interval
    interval_end = interval_start + Platform::ApplicationUsageMetric.interval_duration
    
    log_msg("Rolling up interval: #{interval_start} - #{interval_end}...")

    rollup_log = Platform::RollupLog.create(:interval => interval, :started_at => Time.now)  

    # figure out which apps to calculates stats for. there is no point for having empty records.
    app_ids = Platform::Application.connection.select_values("select distinct application_id from platform_application_users where created_at >= '#{interval_start}' and created_at < '#{interval_end}'")
    app_ids += Platform::Application.connection.select_values("select distinct application_id from platform_application_logs where created_at >= '#{interval_start}' and created_at < '#{interval_end}'")
    
    log_msg("No applications to rollup") if app_ids.empty?
    
    # for each application
    app_ids.uniq.each do |app_id|
      app = Platform::Application.find_by_id(app_id)
      next unless app
      
      # process application metrics
      Platform::ApplicationMetric.calculate_metric(app, interval)
  
      # process application usage metrics - in 15 min chunks only - since it is summable
      Platform::ApplicationUsageMetric.calculate_metric(app, interval)
    end
  
    rollup_log.update_attributes(:finished_at => Time.now)
    
    now = Time.now
    if now >= interval_start && now < interval_end
      log_msg("Rolled up current interval. Going to sleep...")
    else  
      rollup_interval(interval + 15.minutes)
    end
  end
  
  def interval_time_for(time)
    Time.parse("#{time.year}-#{time.month}-#{time.day} #{time.hour}:#{((time.min / 15) * 15) }")
  end
  
  def log_msg(msg)
    pp "#{Time.now.strftime('%m/%d/%Y %H:%M:%S')}: #{msg}"    
  end
  
end