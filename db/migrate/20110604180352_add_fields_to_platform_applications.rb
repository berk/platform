class AddFieldsToPlatformApplications < ActiveRecord::Migration
  def self.up
    add_column :platform_applications, :rank, :integer
    add_column :platform_applications, :auto_signin, :boolean
    add_column :platform_applications, :deauthorize_callback_url, :string
    
    add_column :platform_applications, :mobile_application_type, :string
    add_column :platform_applications, :ios_bundle_id, :string
    add_column :platform_applications, :itunes_app_store_id, :string
    add_column :platform_applications, :android_key_hash, :string
  end

  def self.down
    remove_column :platform_applications, :rank
    remove_column :platform_applications, :auto_signin
    remove_column :platform_applications, :deauthorize_callback_url
    
    remove_column :platform_applications, :mobile_application_type
    remove_column :platform_applications, :ios_bundle_id
    remove_column :platform_applications, :itunes_app_store_id
    remove_column :platform_applications, :android_key_hash
  end
end
