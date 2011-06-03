class CreatePlatformOauthTokens < ActiveRecord::Migration
  def self.up
    create_table :platform_oauth_tokens, :id => false do |t|
      t.column    :id,              :serial_primary_key
      t.integer   :user_id,         :limit=>8
      t.integer   :application_id
      t.string    :type,            :limit => 20
      t.string    :token,           :limit => 50
      t.string    :secret,          :limit => 50
      t.string    :verifier,        :limit => 20
      t.string    :callback_url
      t.timestamp :authorized_at, :invalidated_at
      t.timestamps
    end
    add_index :platform_oauth_tokens, :token, :unique
  end

  def self.down
    drop_table :platform_oauth_tokens
  end
end
