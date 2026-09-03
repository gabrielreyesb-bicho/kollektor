require "test_helper"

class SeriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user   = users(:one)
    @series = series(:one)         # pertenece a @user
    @other  = series(:two)         # pertenece a users(:two)
    sign_in @user
  end

  test "should get index" do
    get series_index_url
    assert_response :success
  end

  test "should get new" do
    get new_series_url
    assert_response :success
  end

  test "should create series" do
    assert_difference("Series.count") do
      post series_index_url, params: { series: {
        name: "Severance", year: 2022, genre_id: @series.genre_id
      } }
    end

    assert_redirected_to series_index_path
  end

  test "should show series" do
    get series_url(@series)
    assert_response :success
  end

  test "should get edit" do
    get edit_series_url(@series)
    assert_response :success
  end

  test "should update series" do
    patch series_url(@series), params: { series: { name: "Renamed Series" } }

    assert_redirected_to series_index_path
    assert_equal "Renamed Series", @series.reload.name
  end

  test "should destroy series" do
    assert_difference("Series.count", -1) do
      delete series_url(@series)
    end

    assert_redirected_to series_index_path
  end

  test "no puedes tocar la serie de otro usuario" do
    delete series_url(@other)

    assert_response :not_found
    assert Series.exists?(@other.id)
  end
end
