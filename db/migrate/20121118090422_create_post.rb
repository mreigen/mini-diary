class CreatePost < ActiveRecord::Migration
  def self.up
    create_table(:posts) do |t|
      t.string :user_id
      t.text :content
      t.string :icon_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
