class SeriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_series, only: [:show, :edit, :update, :destroy, :snooze, :unsnooze]
  before_action :set_title
  before_action :set_form_dependencies, only: [:new, :edit, :create, :update]

  def index
    @series = current_user.series.includes(:genre).order(created_at: :desc)
    if params[:search].present?
      @series = @series.where("LOWER(name) LIKE ? OR LOWER(description) LIKE ?", "%#{params[:search].downcase}%", "%#{params[:search].downcase}%")
    end
  end

  def show
  end

  def new
    @series = current_user.series.build
  end

  def create
    @series = current_user.series.build(series_params)
    
    if @series.save
      redirect_to series_index_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    Rails.logger.debug "=== SERIES UPDATE ==="
    Rails.logger.debug "Params: #{params.inspect}"
    Rails.logger.debug "Series before update: \\#{@series.inspect}"
    if @series.update(series_params)
      Rails.logger.debug "Series after update: \\#{@series.inspect}"
      redirect_path = params[:return_to].presence || series_index_path
      redirect_to redirect_path
    else
      Rails.logger.debug "Update failed: \\#{@series.errors.full_messages}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @series.destroy
    redirect_to series_index_path, status: :see_other
  end

  def snooze
    @series.update(snoozed_at: Time.current)
    redirect_back fallback_location: series_index_path
  end

  def unsnooze
    @series.update(snoozed_at: nil)
    redirect_back fallback_location: series_index_path
  end

  private

  def set_form_dependencies
    @genres = Genre.where(user_id: [current_user.id, nil])
                   .by_collection_type('Series')
                   .order(:name)
    @actors = Actor.order(:name)
  end

  def set_series
    @series = current_user.series.find(params[:id])
  end

  def set_title
    @title = "Series & Movies Collection"
  end

  def series_params
    params.require(:series).permit(:name, :description, :year, :genre_id, :cover_image, :comments, :seen, :imdb_id, actor_ids: [])
  end
end
