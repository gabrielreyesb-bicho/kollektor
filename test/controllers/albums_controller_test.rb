require "test_helper"

class AlbumsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner     = users(:one)
    @stranger  = users(:two)
    @album     = albums(:one)        # pertenece a @owner
    @other_album = albums(:two)      # pertenece a @stranger
  end

  # --- autorización ----------------------------------------------------------
  #
  # Un álbum de otro usuario debe comportarse como si no existiera. Antes el
  # controlador cargaba el álbum con Album.find y solo redirigía, así que
  # destroy alcanzaba a borrarlo de todos modos.

  test "no puedes borrar el álbum de otro usuario" do
    sign_in @stranger

    assert_no_difference "Album.count" do
      delete album_url(@album)
    end

    assert_response :not_found
    assert Album.exists?(@album.id)
  end

  test "no puedes descartar el álbum de otro usuario" do
    sign_in @stranger

    patch dismiss_album_url(@album)

    assert_response :not_found
    assert_not @album.reload.dismissed?
  end

  test "no puedes restaurar el álbum de otro usuario" do
    @album.dismiss!
    sign_in @stranger

    patch restore_album_url(@album)

    assert_response :not_found
    assert @album.reload.dismissed?
  end

  # Nota: cada uno de estos va en su propio test a propósito. Un 404 aborta la
  # respuesta antes de que se re-emita la cookie de sesión, así que encadenar
  # otra petición después de un 404 llegaría sin login y probaría otra cosa.

  test "no puedes ver el álbum de otro usuario" do
    sign_in @stranger

    get album_url(@album)

    assert_response :not_found
  end

  test "no puedes abrir el formulario de edición del álbum de otro usuario" do
    sign_in @stranger

    get edit_album_url(@album)

    assert_response :not_found
  end

  test "no puedes modificar el álbum de otro usuario" do
    sign_in @stranger

    patch album_url(@album), params: { album: { name: "Hijacked" } }

    assert_response :not_found
    assert_equal "Album One", @album.reload.name
  end

  test "sin sesión te manda a login en vez de tocar nada" do
    delete album_url(@album)

    assert_redirected_to new_user_session_url
    assert Album.exists?(@album.id)
  end

  # --- borrar desde el modal de Get Lucky ------------------------------------

  test "borrar desde Get Lucky responde un turbo stream que quita la tarjeta" do
    sign_in @owner

    assert_difference "Album.count", -1 do
      delete album_url(@album), params: { from: "get_lucky" }
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_match %r{action="remove"}, response.body
    assert_match %r{target="lucky_album_#{@album.id}"}, response.body
  end

  test "borrar desde Albums sigue redirigiendo al listado" do
    sign_in @owner

    assert_difference "Album.count", -1 do
      delete album_url(@album)
    end

    assert_redirected_to albums_url
  end

  # --- descartar / restaurar -------------------------------------------------

  test "descartar desde Get Lucky quita la tarjeta sin borrar el álbum" do
    sign_in @owner

    assert_no_difference "Album.count" do
      patch dismiss_album_url(@album), params: { from: "get_lucky" }
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_match %r{target="lucky_album_#{@album.id}"}, response.body
    assert @album.reload.dismissed?
  end

  test "descartar desde la ficha del álbum redirige de vuelta" do
    sign_in @owner

    patch dismiss_album_url(@album), headers: { "HTTP_REFERER" => album_url(@album) }

    assert_redirected_to album_url(@album)
    assert @album.reload.dismissed?
  end

  test "restaurar devuelve el álbum a las sugerencias" do
    @album.dismiss!
    sign_in @owner

    patch restore_album_url(@album), headers: { "HTTP_REFERER" => album_url(@album) }

    assert_redirected_to album_url(@album)
    assert_not @album.reload.dismissed?
  end

  # --- la ficha refleja el estado --------------------------------------------

  test "la ficha ofrece descartar cuando el álbum se sugiere" do
    sign_in @owner

    get album_url(@album)

    assert_response :success
    assert_match "Stop suggesting", response.body
    assert_no_match(/Hidden from Get Lucky/, response.body)
  end

  test "la ficha ofrece restaurar cuando el álbum está descartado" do
    @album.dismiss!
    sign_in @owner

    get album_url(@album)

    assert_response :success
    assert_match "Hidden from Get Lucky", response.body
    assert_match "Suggest again", response.body
  end
end
