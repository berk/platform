class CreatePlatformApplicationMetrics < ActiveRecord::Migration
  def self.up
    create_table :platform_application_metrics, :id => false do |t|
      t.column  :id,                :serial_primary_key
      t.string  :type
      t.integer :application_id
      t.integer :active_user_count
      t.date    :metric_date
      t.timestamps
    end      
    
    add_index :platform_application_metrics, :application_id
  end

  def self.down
    drop_table :platform_application_metrics
  end
end
