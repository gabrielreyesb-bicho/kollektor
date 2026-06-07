module MusicSidebarData
  extend ActiveSupport::Concern

  included do
    before_action :load_music_sidebar_data
  end

  private

  def load_music_sidebar_data
    return unless user_signed_in?

    @title = "Music Collection"
    @genres = Genre.by_collection_type('Music').order(:name)
    @authors ||= current_user.authors.order(:name)
  end
end 