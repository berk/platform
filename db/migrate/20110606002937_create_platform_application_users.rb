class CreatePlatformApplicationUsers < ActiveRecord::Migration
  def self.up
    create_table :platform_application_users, :id => false do |t|
      t.column  :id,              :serial_primary_key
      t.integer :application_id,  :null => false
      t.integer :user_id,         :null => false
      t.timestamps
    end
    add_index :platform_application_users, [:application_id]
    add_index :platform_application_users, [:user_id]
  end

  def self.down
    drop_table :platform_application_users
  end
end
