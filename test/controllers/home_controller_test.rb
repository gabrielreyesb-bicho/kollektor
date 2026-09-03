require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner = users(:one)
    @album = albums(:one)
  end

  test "Get Lucky exige sesión" do
    get get_lucky_url

    assert_redirected_to new_user_session_url
  end

  test "Get Lucky solo sugiere álbumes tuyos" do
    sign_in @owner

    get get_lucky_url

    assert_response :success
    assert_equal [@album], assigns_recommended
  end

  test "Get Lucky no sugiere álbumes descartados" do
    other = create_album("Still Suggested")
    @album.dismiss!
    sign_in @owner

    get get_lucky_url

    assert_response :success
    assert_equal [other], assigns_recommended
    assert_no_match(/lucky_album_#{@album.id}"/, response.body)
  end

  test "Get Lucky sugiere como máximo 4 álbumes" do
    10.times { |i| create_album("Extra #{i}") }
    sign_in @owner

    get get_lucky_url

    assert_response :success
    assert_equal 4, response.body.scan(/id="lucky_album_\d+"/).size
  end

  test "cada sugerencia trae botón de descartar y de borrar" do
    sign_in @owner

    get get_lucky_url

    assert_response :success
    assert_match %r{action="#{Regexp.escape(dismiss_album_path(@album))}"}, response.body
    assert_match %r{action="#{Regexp.escape(album_path(@album))}"}, response.body
    assert_match "bi-trash", response.body
    # El borrado pide confirmación; descartar no, porque es reversible
    assert_match "data-turbo-confirm", response.body
  end

  test "si descartas todo, Get Lucky no sugiere nada" do
    @owner.albums.find_each(&:dismiss!)
    sign_in @owner

    get get_lucky_url

    assert_response :success
    assert_empty assigns_recommended
    assert_match "No albums found", response.body
  end

  private

  def assigns_recommended
    @controller.view_assigns["recommended_albums"]
  end

  def create_album(name)
    @owner.albums.create!(name: name, year: 1990,
                          genre: genres(:one), author: authors(:one))
  end
end
