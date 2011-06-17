class CreateAdmins < ActiveRecord::Migration
  def self.up
    create_table :platform_admins do |t|
      t.integer :user_id
      t.integer :level
      t.timestamps
    end

    add_index :platform_admins, [:user_id]
  end

  def self.down
    drop_table :platform_admins
  end
end
