namespace :platform do
  
  desc "Initializes all of the tables with default data"
  task :init => :environment do
    raise "This action is prohibited in this environment" if ['production', 'stage', 'staging'].include?(Rails.env) and env('force') != 'true'
    Platform::Config.reset_all!
  end
  
  task :rollup_metrics => :environment do
    # for debugging purposes
    Platform::RollupLog.delete_all
    
    # when we bootstrap the process, we should havesome set date/time from where to start
    default_start_time = Time.parse("Mon Jun 20 20:45:48 -0700 2011")
    
    if Platform::RollupLog.first == nil
      # running the rollup for the first time
      interval = interval_time_for(default_start_time)
    else
      last_rollup = Platform::RollupLog.last
      interval = interval_time_for(last_rollup.created_at)
    end
    
    rollup_interval(interval)
  end
  
  def rollup_interval(interval)
    interval_start = interval
    interval_end = interval_start + 15.minutes

    pp "Rolling up interval: #{interval_start} - #{interval_end}..."
    
    rollup_log = Platform::RollupLog.create(:interval => interval, :started_at => Time.now)  
    
    Platform::Application.all.each do |app|
      Platform::ApplicationLog.find(:all, :conditions => [""])
      
    end
  
    rollup_log.update_attributes(:finished_at => Time.now)
    
    now = Time.now
    if now >= interval_start && now < interval_end
      pp "Rolled up current interval. Going to sleep..."
    else  
      rollup_interval(interval + 15.minutes)
    end
  end
  
  def interval_time_for(time)
    Time.parse("#{time.year}-#{time.month}-#{time.day} #{time.hour}:#{((time.min % 15) * 15) }")
  end
    
    
  
end