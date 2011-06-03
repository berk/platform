class CreatePlatformApplications < ActiveRecord::Migration
  def self.up
    create_table :platform_applications, :id => false do |t|
      t.column  :id,                :serial_primary_key
      t.integer :developer_id
      t.string  :name
      t.text    :description
      t.string  :state,             :default => "new"
      t.string  :locale
      t.string  :url
      t.string  :support_url
      t.string  :callback_url
      t.string  :contact_email
      t.string  :privacy_policy_url
      t.string  :terms_of_service_url
      t.string  :permissions
      t.string  :key
      t.string  :secret
      t.integer :icon_id
      t.integer :logo_id
      t.string  :canvas_name
      t.string  :canvas_url
      t.boolean :auto_resize
      t.boolean :auto_login
      t.timestamps
    end
    
    add_index :platform_applications, :developer_id
    add_index :platform_applications, :key, :unique
  end

  def self.down
    drop_table :platform_applications
  end
end
