class CreatePlatformPermissions < ActiveRecord::Migration
  def self.up
    create_table :platform_permissions, :id => false do |t|
      t.column  :id,              :serial_primary_key
      t.string  :keyword,         :null => false
      t.text    :description,     :null => false
      t.timestamps
    end
    add_index :platform_permissions, [:keyword]
  end

  def self.down
    drop_table :platform_permissions
  end
end
