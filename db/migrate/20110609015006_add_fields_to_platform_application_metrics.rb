class AddFieldsToPlatformApplicationMetrics < ActiveRecord::Migration
  def self.up
    add_column :platform_application_metrics, :new_user_count, :integer
    add_column :platform_application_metrics, :canvas_view_count, :integer
    add_column :platform_application_metrics, :canvas_avg_view_response_time, :integer
    add_column :platform_application_metrics, :canvas_error_count, :integer
    add_column :platform_application_metrics, :api_call_count, :integer
    add_column :platform_application_metrics, :api_avg_response_time, :integer
    add_column :platform_application_metrics, :api_error_count, :integer
    add_column :platform_application_metrics, :oauth_impression_count, :integer
    add_column :platform_application_metrics, :oauth_accept_count, :integer
  end

  def self.down
    remove_column :platform_application_metrics, :new_user_count
    remove_column :platform_application_metrics, :canvas_view_count
    remove_column :platform_application_metrics, :canvas_avg_view_response_time
    remove_column :platform_application_metrics, :canvas_error_count
    remove_column :platform_application_metrics, :api_call_count
    remove_column :platform_application_metrics, :api_avg_response_time
    remove_column :platform_application_metrics, :api_error_count
    remove_column :platform_application_metrics, :oauth_impression_count
    remove_column :platform_application_metrics, :oauth_accept_count
  end
end
