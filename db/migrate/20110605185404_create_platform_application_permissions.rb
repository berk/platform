class CreatePlatformApplicationPermissions < ActiveRecord::Migration
  def self.up
    create_table :platform_application_permissions, :id => false do |t|
      t.column  :id,              :serial_primary_key
      t.integer :application_id
      t.integer :permission_id
      t.timestamps
    end
    add_index :platform_application_permissions, :application_id
  end

  def self.down
    drop_table :platform_application_permissions
  end
end
