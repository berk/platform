class CreatePlatformOauthNonces < ActiveRecord::Migration
  def self.up
    create_table :platform_oauth_nonces, :id => false do |t|
      t.column    :id,              :serial_primary_key
      t.string    :nonce
      t.integer   :timestamp
      t.integer   :oauth_token_id
      t.string    :oauth_token_type
      t.timestamps
    end
    add_index :platform_oauth_nonces, [:nonce, :timestamp], :unique
  end

  def self.down
    drop_table :platform_oauth_nonces
  end
end
