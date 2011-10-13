class CreateBookmarks < ActiveRecord::Migration
  def change
    create_table :bookmarks do |t|
      t.integer :user_id
      t.string  :title  
      t.string  :url
      t.timestamps
    end
  end
end
