class CreatePlatformRatings < ActiveRecord::Migration
  def self.up
    create_table :platform_ratings, :id => false do |t|
      t.column    :id,              :serial_primary_key
      t.integer   :user_id,         :limit => 8, :null => false 
      t.string    :object_type
      t.integer   :object_id
      t.integer   :value
      t.text      :comment
      t.timestamps
    end
    add_index :platform_ratings, :user_id
    add_index :platform_ratings, [:object_type, :object_id]
  end

  def self.down
    drop_table :platform_ratings
  end
end
