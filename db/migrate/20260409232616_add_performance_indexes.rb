class AddPerformanceIndexes < ActiveRecord::Migration[7.1]
  def change
    # albums: foreign keys and name search
    add_index :albums, :user_id, if_not_exists: true
    add_index :albums, :genre_id, if_not_exists: true
    add_index :albums, :author_id, if_not_exists: true
    add_index :albums, :name, if_not_exists: true

    # authors: foreign keys and name search
    add_index :authors, :user_id, if_not_exists: true
    add_index :authors, :genre_id, if_not_exists: true
    add_index :authors, :name, if_not_exists: true

    # genres
    add_index :genres, :name, if_not_exists: true
    add_index :genres, :collection_type_id, if_not_exists: true
  end
end
