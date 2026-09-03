require "test_helper"

class AlbumTest < ActiveSupport::TestCase
  setup do
    @user  = users(:one)
    @album = albums(:one)
  end

  # --- descartar / restaurar -------------------------------------------------

  test "un álbum recién creado es sugerible" do
    assert_not @album.dismissed?
    assert_includes Album.suggestable, @album
  end

  test "dismiss! saca el álbum de las sugerencias pero lo deja en la colección" do
    @album.dismiss!

    assert @album.dismissed?
    assert_not_nil @album.dismissed_at
    assert Album.exists?(@album.id), "descartar no debe borrar el álbum"
    assert_includes @user.albums, @album, "debe seguir en la colección del usuario"
    assert_not_includes Album.suggestable, @album
  end

  test "restore! devuelve el álbum a las sugerencias" do
    @album.dismiss!
    @album.restore!

    assert_not @album.dismissed?
    assert_nil @album.dismissed_at
    assert_includes Album.suggestable, @album
  end

  test "suggestable solo excluye los descartados" do
    keeper = create_album(name: "Keeper", likes: 0)
    dropped = create_album(name: "Dropped", likes: 0)
    dropped.dismiss!

    suggestable = @user.albums.suggestable

    assert_includes suggestable, keeper
    assert_not_includes suggestable, dropped
  end

  # --- orden de sugerencias --------------------------------------------------

  test "suggestions_order prioriza los álbumes con menos likes" do
    listened_a_lot = create_album(name: "Heard Often", likes: 12)
    listened_once  = create_album(name: "Heard Once",  likes: 1)
    never_heard    = create_album(name: "Never Heard", likes: 0)

    order = @user.albums.where(id: [listened_a_lot.id, listened_once.id, never_heard.id])
                 .suggestions_order.to_a

    assert_equal [never_heard, listened_once, listened_a_lot], order
  end

  test "suggestions_order no repite siempre el mismo álbum a igualdad de likes" do
    20.times { |i| create_album(name: "Tied #{i}", likes: 0) }
    scope = @user.albums.suggestable.suggestions_order.limit(1)

    # Sin `uncached` esto siempre devolvería el mismo id: el RANDOM() viaja
    # dentro del SQL, así que el query cache lo trata como la misma consulta.
    # En producción no pasa — cada request estrena cache y Get Lucky consulta
    # una sola vez.
    firsts = Album.uncached { 15.times.map { scope.reload.first.id }.uniq }

    assert_operator firsts.size, :>, 1,
      "con 20 álbumes empatados en likes, 15 tiradas no deberían dar siempre el mismo"
  end

  private

  def create_album(name:, likes:)
    @user.albums.create!(name: name, year: 1990, likes_count: likes,
                         genre: genres(:one), author: authors(:one))
  end
end
