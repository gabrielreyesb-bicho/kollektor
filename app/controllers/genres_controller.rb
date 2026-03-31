class GenresController < ApplicationController
  include MusicSidebarData
  
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
    if @genre.update(genre_params)
      redirect_to genres_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize_genre_access
    @genre.destroy!
    redirect_to genres_url, notice: 'Genre was successfully destroyed.'
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