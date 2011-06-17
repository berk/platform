class CreatePlatformRollupLogs < ActiveRecord::Migration
  def self.up
    create_table :platform_rollup_logs, :id => false do |t|
      t.column     :id,                 :serial_primary_key
      t.timestamp  :interval 
      t.timestamp  :started_at
      t.timestamp  :finished_at

      t.timestamps
    end
    add_index :platform_rollup_logs, :interval
  end

  def self.down
    drop_table :platform_rollup_logs
  end
end
