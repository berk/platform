class CreatePlatformDevelopers < ActiveRecord::Migration
  def self.up
    create_table :platform_developers, :id => false do |t|
      t.column  :id, :serial_primary_key
      t.integer :user_id, :limit => 8, :null => false
      t.string  :name, :null => false
      t.text    :about
      t.string  :url
      t.string  :email
      t.string  :phone
      t.timestamps
    end
    
    add_index :platform_developers, :user_id
  end

  def self.down
    drop_table :platform_developers
  end
end
