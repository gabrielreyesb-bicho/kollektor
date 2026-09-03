require "test_helper"

class AuthorsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user   = users(:one)
    @author = authors(:one)        # pertenece a @user
    @other  = authors(:two)        # pertenece a users(:two)
    sign_in @user
  end

  test "should get index" do
    get authors_url
    assert_response :success
  end

  test "should get new" do
    get new_author_url
    assert_response :success
  end

  test "should create author" do
    assert_difference("Author.count") do
      post authors_url, params: { author: {
        name: "Gentle Giant",
        description: @author.description,
        genre_id: @author.genre_id,
        country_id: countries(:uk).id
      } }
    end

    assert_redirected_to authors_path
  end

  test "should show author" do
    get author_url(@author)
    assert_response :success
  end

  test "should get edit" do
    get edit_author_url(@author)
    assert_response :success
  end

  test "should update author" do
    patch author_url(@author), params: { author: { name: "Renamed Author" } }

    assert_redirected_to authors_path
    assert_equal "Renamed Author", @author.reload.name
  end

  test "should destroy author" do
    assert_difference("Author.count", -1) do
      delete author_url(@author)
    end

    assert_redirected_to authors_path
  end

  test "no puedes tocar el autor de otro usuario" do
    delete author_url(@other)

    assert_response :not_found
    assert Author.exists?(@other.id)
  end
end
