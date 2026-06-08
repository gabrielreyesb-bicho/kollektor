class CountriesController < ApplicationController
  include MusicSidebarData
  
  before_action :set_country, only: %i[ show edit update destroy ]
  before_action :set_collection_context, only: [:index, :new, :edit]

  def index
    @countries = Country.all.order(:name)
  end

  def new
    @country = Country.new
  end

  def edit
  end

  def create
    @country = Country.new(country_params)
    if @country.save
      redirect_to countries_path(collection_type: params[:country][:collection_type]), notice: 'Country was successfully created.'
    else
      set_collection_context
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @country.update(country_params)
      redirect_to countries_path(collection_type: params[:country][:collection_type]), notice: 'Country was successfully updated.'
    else
      set_collection_context
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @country.destroy!
    redirect_to countries_path(collection_type: params[:collection_type]), status: :see_other, notice: 'Country was successfully destroyed.'
  end

  private
    def set_collection_context
      @collection_type = params[:collection_type] || 'Music'
      @title = @collection_type == 'Series' ? 'Series Collection' : 'Music Collection'
    end

    def set_country
      @country = Country.find(params[:id])
    end

    def country_params
      params.require(:country).permit(:name, :code)
    end
end 