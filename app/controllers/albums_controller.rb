class AlbumsController < ApplicationController
  include MusicSidebarData
  
  before_action :set_album, only: %i[ show edit update destroy ]
  before_action :load_dependencies, only: %i[ new edit create update ]

  def index
    @albums = current_user.albums.includes(:genre, :author)
    @albums = @albums.search(params[:search]) if params[:search].present?
    @albums = @albums.order(:name)
    puts "DEBUG_DB_URL: #{ENV['DATABASE_URL']}"
  end

  def show
    authorize_album_access
  end

  def new
    @album = Album.new
  end

  def edit
    authorize_album_access
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
    authorize_album_access
    if @album.update(album_params)
      redirect_to albums_path
    else
      load_dependencies
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize_album_access
    @album.destroy!
    redirect_to albums_url
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
    def set_album
      @album = Album.find(params[:id])
    end

    def authorize_album_access
      unless @album.user == current_user
        flash[:alert] = "You are not authorized to access this album"
        redirect_to albums_path
      end
    end

    def load_dependencies
      # Try to get genres by collection type, fallback to all genres if collection type doesn't exist
      music_collection_type = CollectionType.find_by(name: 'Music')
      if music_collection_type
        @genres = Genre.by_collection_type('Music').order(:name)
        @authors = current_user.authors.by_collection_type('Music').all
      else
        # Fallback: get all genres and authors if collection type doesn't exist
        @genres = Genre.order(:name)
        @authors = current_user.authors.all
      end
    end

    def album_params
      params.require(:album).permit(:name, :description, :year,
                                  :genre_id, :author_id, :cover_image)
    end
end 