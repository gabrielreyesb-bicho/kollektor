class ActorsController < ApplicationController
  before_action :set_actor, only: [:show, :edit, :update, :destroy]
  before_action :set_title

  def index
    @actors = Actor.all.order(:name)
  end

  def show
  end

  def new
    @actor = Actor.new
  end

  def create
    @actor = Actor.new(actor_params)
    if @actor.save
      redirect_to actors_path, notice: 'Actor was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @actor.update(actor_params)
      redirect_to actors_path, notice: 'Actor was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @actor.destroy
    redirect_to actors_path, status: :see_other, notice: 'Actor was successfully destroyed.'
  end

  private

  def set_title
    @title = "Series & Movies Collection"
  end

  def set_actor
    @actor = Actor.find(params[:id])
  end

  def actor_params
    params.require(:actor).permit(:name, :bio, :photo)
  end
end
