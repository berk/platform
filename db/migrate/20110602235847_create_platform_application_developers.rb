class CreatePlatformApplicationDevelopers < ActiveRecord::Migration
  def self.up
    create_table :platform_application_developers, :id => false do |t|
      t.column  :id,                :serial_primary_key
      t.integer :application_id
      t.integer :developer_id
      t.timestamps
    end
    
    add_index :platform_application_developers, :application_id
    add_index :platform_application_developers, :developer_id
  end

  def self.down
    drop_table :platform_application_developers
  end
end
