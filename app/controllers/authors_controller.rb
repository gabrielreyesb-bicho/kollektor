class AuthorsController < ApplicationController
  include MusicSidebarData

  skip_before_action :load_music_sidebar_data
  before_action :set_author, only: %i[ show edit update destroy ]
  before_action :set_form_dependencies, only: %i[ new edit create update ]
  before_action :load_sidebar_data, only: %i[ index show ]

  def index
    @authors = current_user.authors.includes(:genre, :country, image_attachment: :blob)
    @authors = @authors.search(params[:search]) if params[:search].present?
    @authors = @authors.where(genre_id: params[:genre_id]) if params[:genre_id].present?
    @authors = @authors.order(:name)
    @title = "Music Collection"
  end

  def show
  end

  def new
    @author = current_user.authors.build
  end

  def edit
  end

  def create
    @author = current_user.authors.build(author_params)

    if @author.save
      redirect_to authors_path, notice: 'Author was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @author.update(author_params)
      redirect_to authors_path, notice: 'Author was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @author.destroy
    redirect_to authors_path, notice: 'Author was successfully destroyed.'
  end

  private
  
  def load_sidebar_data
    @genres = Genre.by_collection_type('Music').order(:name)
    @authors = current_user.authors.order(:name)
  end

  def set_form_dependencies
    @countries = Country.order(:name)
    @genres = Genre.by_collection_type('Music').order(:name)
    @authors = current_user.authors.order(:name)
  end

  def set_author
    @author = current_user.authors.find(params[:id])
  end

  def author_params
    params.require(:author).permit(:name, :description, :genre_id, :country_id, :image)
  end
end 