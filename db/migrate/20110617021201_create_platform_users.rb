class CreatePlatformUsers < ActiveRecord::Migration
  def self.up
    create_table :platform_users do |t|
      t.string  :name
      t.string  :gender
      t.string  :email
      t.string  :password
      t.string  :mugshot
      t.string  :link
      t.string  :locale
      t.timestamps
    end
    add_index :platform_users, [:email]
    add_index :platform_users, [:email, :password]         
  end

  def self.down
    drop_table :platform_users
  end
end
