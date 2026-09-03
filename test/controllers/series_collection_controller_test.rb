require "test_helper"

class SeriesCollectionControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get index" do
    sign_in users(:one)

    get series_collection_index_url

    assert_response :success
  end

  test "index exige sesión" do
    get series_collection_index_url

    assert_redirected_to new_user_session_url
  end
end
