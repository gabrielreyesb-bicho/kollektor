class GenresController < ApplicationController
  include MusicSidebarData

  skip_before_action :load_music_sidebar_data, only: %i[ new edit create update destroy ]
  before_action :set_genre, only: %i[ show edit update destroy ]

  def index
    @collection_type = params[:collection_type] || 'Music'
    @genres = Genre.where(user_id: [current_user.id, nil])
                   .by_collection_type(@collection_type)
    @title = @collection_type == 'Series' ? 'Series & Movies Collection' : 'Music Collection'

    if params[:search].present?
      @genres = @genres.search(params[:search])
    end
  end

  def show
    authorize_genre_access
  end

  def new
    @genre = current_user.genres.build
    set_collection_context
    @genre.collection_type ||= CollectionType.find_by(name: 'Music')
  end

  def edit
    authorize_genre_access
    set_collection_context
  end

  def create
    @genre = current_user.genres.build(genre_params)
    if @genre.save
      redirect_to genres_path(collection_type: @genre.collection_type.name), notice: 'Genre was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize_genre_access

    Rails.logger.info "=== GENRE UPDATE DEBUG ==="
    Rails.logger.info "Genre ID: #{@genre.id}"
    Rails.logger.info "Params received: #{genre_params.inspect}"
    Rails.logger.info "Image param present: #{params[:genre][:image].present? rescue 'error reading'}"
    Rails.logger.info "Active Storage service: #{ActiveStorage::Blob.service.class.name}"
    Rails.logger.info "MINIO_ENDPOINT: #{ENV['MINIO_ENDPOINT'].inspect}"
    Rails.logger.info "MINIO_BUCKET: #{ENV['MINIO_BUCKET'].inspect}"
    Rails.logger.info "MINIO_ACCESS_KEY set: #{ENV['MINIO_ACCESS_KEY'].present?}"

    if @genre.update(genre_params)
      Rails.logger.info "=== UPDATE SUCCESS — image attached: #{@genre.image.attached?} ==="
      redirect_to genres_path
    else
      Rails.logger.info "=== UPDATE FAILED — errors: #{@genre.errors.full_messages} ==="
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize_genre_access
    @genre.destroy!
    redirect_to genres_url, status: :see_other, notice: 'Genre was successfully destroyed.'
  end

  private
    def set_collection_context
      if params[:collection_type]
        @collection_type = params[:collection_type]
        collection_type_record = CollectionType.find_by(name: @collection_type)
        @genre.collection_type = collection_type_record if collection_type_record
      elsif @genre&.collection_type
        @collection_type = @genre.collection_type.name
      else
        @collection_type = 'Music'
      end
      @title = @collection_type == 'Series' ? 'Series & Movies Collection' : 'Music Collection'
    end

    def set_genre
      @genre = Genre.find(params[:id])
    end

    def authorize_genre_access
      unless @genre.user == current_user
        flash[:alert] = "You are not authorized to access this genre"
        redirect_to genres_path
      end
    end

    def genre_params
      params.require(:genre).permit(:name, :description, :collection_type_id, :image)
    end
end 