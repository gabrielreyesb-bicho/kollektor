require "test_helper"

# El mood prompt diario (mood_prompt_controller.js) pega a este endpoint. Es la
# segunda superficie que sugiere álbumes al azar, así que también tiene que
# respetar los descartes — si no, un álbum que sacaste de Get Lucky te seguiría
# apareciendo aquí.
class Api::RecommendationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user  = users(:one)
    @album = albums(:one)
    sign_in @user
  end

  test "las sugerencias al azar omiten los álbumes descartados" do
    kept = create_album("Kept Around")
    @album.dismiss!

    get "/api/recommendations/by_genre/random"

    assert_response :success
    assert_equal [kept], recommended
  end

  test "las sugerencias por género omiten los álbumes descartados" do
    kept = create_album("Kept Around")
    @album.dismiss!

    get "/api/recommendations/by_genre/#{genres(:one).id}"

    assert_response :success
    assert_equal [kept], recommended
  end

  test "solo sugiere álbumes del usuario en sesión" do
    get "/api/recommendations/by_genre/random"

    assert_response :success
    assert_equal [@album], recommended
    assert_not_includes recommended, albums(:two)
  end

  private

  def recommended
    @controller.view_assigns["recommended_albums"].to_a
  end

  def create_album(name)
    @user.albums.create!(name: name, year: 1990,
                         genre: genres(:one), author: authors(:one))
  end
end
