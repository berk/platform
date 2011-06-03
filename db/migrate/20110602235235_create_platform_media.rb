class CreatePlatformMedia < ActiveRecord::Migration
  def self.up
    create_table :platform_media, :id => false do |t|
      t.column  :id,                :serial_primary_key
      t.string  :type
      t.string  :file_location
    end
  end

  def self.down
    drop_table :platform_media
  end
end
