class DropUnusedSeriesTables < ActiveRecord::Migration[7.1]
  def up
    drop_table :actors_series
    drop_table :authors_series
    drop_table :actors
    drop_table :tv_shows
    remove_column :series, :snoozed_at
  end

  def down
    create_table :actors do |t|
      t.string :name
      t.text :bio
      t.timestamps
    end

    create_table :actors_series, id: false do |t|
      t.integer :actor_id, null: false
      t.integer :series_id, null: false
    end

    create_table :authors_series, id: false do |t|
      t.integer :series_id, null: false
      t.integer :author_id, null: false
    end

    create_table :tv_shows do |t|
      t.string :name
      t.text :description
      t.integer :year
      t.integer :genre_id, null: false
      t.integer :author_id, null: false
      t.integer :user_id, null: false
      t.timestamps
      t.index :author_id
      t.index :genre_id
      t.index :user_id
    end
    add_foreign_key :tv_shows, :authors
    add_foreign_key :tv_shows, :genres
    add_foreign_key :tv_shows, :users

    add_column :series, :snoozed_at, :datetime
  end
end
