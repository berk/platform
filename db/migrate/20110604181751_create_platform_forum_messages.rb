class CreatePlatformForumMessages < ActiveRecord::Migration
  def self.up
    create_table :platform_forum_messages, :id => false do |t|
      t.column  :id,              :serial_primary_key
      t.integer :forum_topic_id,  :null => false
      t.integer :user_id,         :null => false
      t.text    :message,         :null => false
      t.timestamps
    end
    add_index :platform_forum_messages, [:forum_topic_id]
    add_index :platform_forum_messages, [:user_id]
  end

  def self.down
    drop_table :platform_forum_messages
  end
end

