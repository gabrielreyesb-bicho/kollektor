class AddDismissedAtToAlbums < ActiveRecord::Migration[7.1]
  def change
    add_column :albums, :dismissed_at, :datetime
  end
end
