class RequireUserOnGenresAuthorsAlbums < ActiveRecord::Migration[7.1]
  TABLES = %i[genres authors albums].freeze

  def up
    # Backfill defensivo: si quedara algún registro sin usuario (p. ej. géneros
    # globales en entornos de desarrollo), asignarlo al primer usuario. En
    # producción no hay ninguno en NULL, así que esto es no-op.
    default_user_id = select_value("SELECT MIN(id) FROM users")
    if default_user_id
      TABLES.each do |t|
        execute "UPDATE #{t} SET user_id = #{default_user_id} WHERE user_id IS NULL"
      end
    end

    TABLES.each do |t|
      change_column_null t, :user_id, false
      add_foreign_key t, :users unless foreign_key_exists?(t, :users)
    end
  end

  def down
    TABLES.each do |t|
      remove_foreign_key t, :users if foreign_key_exists?(t, :users)
      change_column_null t, :user_id, true
    end
  end
end
