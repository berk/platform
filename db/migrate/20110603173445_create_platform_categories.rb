class CreatePlatformCategories < ActiveRecord::Migration
  def self.up
    create_table :platform_categories, :id => false do |t|
      t.column    :id,              :serial_primary_key
      t.string    :type
      t.string    :name
      t.string    :keyword
      t.integer   :position 
      t.date      :enable_on
      t.date      :disable_on
      t.integer   :parent_id 
      t.timestamps
    end
    add_index :platform_categories, :parent_id
  end

  def self.down
    drop_table :platform_categories
  end
end
