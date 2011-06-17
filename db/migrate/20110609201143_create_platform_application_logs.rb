class CreatePlatformApplicationLogs < ActiveRecord::Migration
  def self.up
    create_table :platform_application_logs, :id => false do |t|
      t.column      :id,                 :serial_primary_key
      t.integer     :application_id
      t.integer     :user_id
      t.string      :event 
      t.text        :data 

      t.timestamps
    end
    add_index :platform_application_logs, [:application_id]
  end

  def self.down
    drop_table :platform_application_logs
  end
end
