class Platform::Admin::MetricsController < Platform::Admin::BaseController

  def index
    @metrics = Platform::ApplicationMetric.filter(:params => params, :filter => Platform::ApplicationMetricFilter)
  end

  def usage
    @metrics = Platform::ApplicationUsageMetric.filter(:params => params, :filter => Platform::ApplicationUsageMetricFilter)
  end
  
  def application_log
    @logs = Platform::ApplicationLog.filter(:params => params, :filter => Platform::ApplicationLogFilter)
  end
  
  def rollup_log
    @logs = Platform::RollupLog.filter(:params => params, :filter => Platform::RollupLogFilter)
  end
  
end
