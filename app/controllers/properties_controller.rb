class PropertiesController < ApplicationController
  before_action :set_property, only: %i[ show update destroy ]
  before_action :authenticate_user!, only: [:new, :create]
  before_action :check_ownership, only: [:edit, :update, :destroy]

  # GET /properties
  def index
    if params[:user_id]
      @properties = Property.where(user_id: params[:user_id])
    else
      @properties = Property.all
    end
    render json: @properties
  end

  # GET /properties/1
  def show
    render json: @property, include: :user
  end

  # POST /properties
  def create
    @property = current_user.properties.new(property_params)
    if @property.save
      render json: @property, status: :created, location: @property
    else
      render json: @property.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /properties/1
  def update
    if @property.update(property_params)
      render json: @property
    else
      render json: @property.errors, status: :unprocessable_entity
    end
  end

  # DELETE /properties/1
  def destroy
    @property.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_property
      @property = Property.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def property_params
      params.require(:property).permit(:user_id, :title, :price, :description, :private)
    end

    def check_ownership
      @property = Property.find(params[:id])
      unless @property.user == current_user
        render json: { error: "Vous n'avez pas la permission d'effectuer cette action." }, status: :forbidden
      end
    end

end
