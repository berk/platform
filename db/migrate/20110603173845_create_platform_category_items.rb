class CreatePlatformCategoryItems < ActiveRecord::Migration
  def self.up
    create_table :platform_category_items, :id => false do |t|
      t.column    :id,              :serial_primary_key
      t.integer   :category_id,     :null => false
      t.string    :item_type
      t.integer   :item_id
      t.integer   :position
      t.timestamps
    end
    add_index :platform_category_items, :category_id
    add_index :platform_category_items, [:item_type, :item_id]
  end

  def self.down
    drop_table :platform_category_items
  end
end
