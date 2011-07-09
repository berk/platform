class Platform::DailyApplicationMetric < Platform::ApplicationMetric

  def self.interval_duration
    1.day
  end


end
