require "test_helper"

class GenresControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user  = users(:one)
    @genre = genres(:one)          # pertenece a @user
    @other = genres(:two)          # pertenece a users(:two)
    sign_in @user
  end

  test "should get index" do
    get genres_url
    assert_response :success
  end

  test "should get new" do
    get new_genre_url
    assert_response :success
  end

  test "should create genre" do
    assert_difference("Genre.count") do
      post genres_url, params: { genre: {
        name: "Canterbury Scene",
        description: @genre.description,
        collection_type_id: collection_types(:music).id
      } }
    end

    assert_redirected_to genres_path(collection_type: "Music")
  end

  test "should show genre" do
    get genre_url(@genre)
    assert_response :success
  end

  test "should get edit" do
    get edit_genre_url(@genre)
    assert_response :success
  end

  test "should update genre" do
    patch genre_url(@genre), params: { genre: { name: "Symphonic Prog" } }

    assert_redirected_to genres_path
    assert_equal "Symphonic Prog", @genre.reload.name
  end

  test "should destroy genre" do
    assert_difference("Genre.count", -1) do
      delete genre_url(@genre)
    end

    assert_redirected_to genres_url
  end

  # Genre cascadea a authors/albums/series, así que un destroy no autorizado
  # borraría la colección completa del otro usuario.
  test "no puedes borrar el género de otro usuario" do
    assert_no_difference ["Genre.count", "Album.count", "Author.count"] do
      delete genre_url(@other)
    end

    assert_response :not_found
    assert Genre.exists?(@other.id)
  end

  test "no puedes ver el género de otro usuario" do
    get genre_url(@other)
    assert_response :not_found
  end

  test "no puedes modificar el género de otro usuario" do
    patch genre_url(@other), params: { genre: { name: "Hijacked" } }

    assert_response :not_found
    assert_equal "Jazz Fusion", @other.reload.name
  end
end
