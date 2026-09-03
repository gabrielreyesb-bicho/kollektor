class AlbumsController < ApplicationController
  include MusicSidebarData

  skip_before_action :load_music_sidebar_data
  before_action :set_album, only: %i[ show edit update destroy dismiss restore ]
  before_action :load_dependencies, only: %i[ new edit create update ]
  before_action :load_sidebar_data, only: %i[ index show ]

  def index
    @albums = current_user.albums.includes(:genre, :author)
    @albums = @albums.search(params[:search]) if params[:search].present?
    @albums = @albums.where(genre_id: params[:genre_id]) if params[:genre_id].present?
    @albums = @albums.where(author_id: params[:author_id]) if params[:author_id].present?
    # Ordenar alfabéticamente por autor, luego álbum y año.
    @albums = @albums.joins(:author).order("authors.name ASC, albums.name ASC, albums.year ASC")

    # Filter options built from genres/authors actually used by the user's
    # albums, so every option matches real album records (avoids duplicate
    # genres from other users yielding empty results).
    @filter_genres = Genre.where(id: current_user.albums.select(:genre_id)).order(:name)
    @filter_authors = Author.where(id: current_user.albums.select(:author_id)).order(:name)
  end

  def show
  end

  def new
    @album = Album.new
  end

  def edit
  end

  def create
    @album = current_user.albums.new(album_params.except(:cover_image))
    cover_image = params[:album][:cover_image] if params[:album]

    begin
      if @album.save
        if cover_image.present?
          begin
            @album.cover_image.attach(cover_image)
          rescue => image_error
            # Silently handle image errors
          end
        end
        
        redirect_to albums_path and return
      else
        load_dependencies
        render :new, status: :unprocessable_entity and return
      end
    rescue => e
      if @album.persisted?
        redirect_to albums_path and return
      else
        load_dependencies
        flash.now[:alert] = "An error occurred while creating the album."
        render :new, status: :unprocessable_entity and return
      end
    end
  end

  def update
    if @album.update(album_params)
      redirect_to albums_path
    else
      load_dependencies
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @album.destroy!

    if from_get_lucky?
      render turbo_stream: remove_suggestion_stream
    else
      redirect_to albums_url, status: :see_other
    end
  end

  # Saca el álbum de las sugerencias de Get Lucky sin borrarlo de la colección.
  def dismiss
    @album.dismiss!

    if from_get_lucky?
      render turbo_stream: remove_suggestion_stream
    else
      redirect_back fallback_location: album_path(@album), status: :see_other
    end
  end

  def restore
    @album.restore!
    redirect_back fallback_location: album_path(@album), status: :see_other
  end

  def search_info
    query = params[:query]
    # Add your search logic here
    # For example, using an external API or database search
    
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          "search_results",
          partial: "search_results",
          locals: { results: @results }
        )
      end
    end
  end

  private
    # Scoped al dueño: un álbum de otro usuario simplemente no existe para esta
    # sesión (404), en vez de cargarse y depender de un chequeo posterior.
    def set_album
      @album = current_user.albums.find(params[:id])
    end

    # Get Lucky vive en un modal dentro de un turbo frame: ahí la respuesta es
    # un stream que quita la tarjeta, no una redirección que cerraría el modal.
    def from_get_lucky?
      params[:from] == "get_lucky"
    end

    def remove_suggestion_stream
      turbo_stream.remove("lucky_album_#{@album.id}")
    end

    def load_sidebar_data
      @title = "Music Collection"
      @genres = Genre.by_collection_type('Music').order(:name)
      @authors = current_user.authors.order(:name)
    end

    def load_dependencies
      @genres = Genre.by_collection_type('Music').order(:name)
      @authors = current_user.authors.by_collection_type('Music').order(:name)
    end

    def album_params
      params.require(:album).permit(:name, :description, :year,
                                  :genre_id, :author_id, :cover_image)
    end
end 