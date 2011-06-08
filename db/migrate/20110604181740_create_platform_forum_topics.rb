class CreatePlatformForumTopics < ActiveRecord::Migration
  def self.up
    create_table :platform_forum_topics, :id => false do |t|
      t.column  :id,              :serial_primary_key
      t.string  :subject_type
      t.integer :subject_id
      t.integer :user_id,         :null => false
      t.text    :topic,           :null => false
      t.timestamps
    end
    add_index :platform_forum_topics, [:subject_type, :subject_id]
    add_index :platform_forum_topics, [:user_id]
  end

  def self.down
    drop_table :platform_forum_topics
  end
end
