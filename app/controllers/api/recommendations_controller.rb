class Api::RecommendationsController < ApplicationController

  def by_genre
    Rails.logger.info("Recommendations request - User: #{current_user.id}, Genre ID: #{params[:id]}")
    
    if params[:id] == 'random'
      @recommended_albums = if Genre.exists?
        get_random_recommendations
      else
        []
      end
      @random_selection = true
    else
      @genre = Genre.find(params[:id])
      @recommended_albums = current_user.albums.joins(:author)  # Join with authors to sort by author name
                               .where(genre_id: @genre.id)
                               .includes(:author, :genre)
                               .order('authors.name ASC, albums.year ASC')
                               .limit(4)
    end

    Rails.logger.info("Recommendations found: #{@recommended_albums.size} albums")
    render partial: 'recommendations'
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("Record not found in recommendations: #{e.message}")
    @recommended_albums = []
    render partial: 'recommendations', status: :not_found
  rescue StandardError => e
    Rails.logger.error("Error in recommendations: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    @recommended_albums = []
    render partial: 'recommendations', status: :internal_server_error
  end

  private

  def get_random_recommendations
    current_user.albums.includes(:author, :genre).with_attached_cover_image
                .weighted_by_likes
                .limit(4)
                .to_a
  end
end 