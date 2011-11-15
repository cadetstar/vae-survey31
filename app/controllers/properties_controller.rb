class PropertiesController < ApplicationController
  before_filter :authenticate_user!, :only => :show
  before_filter :is_administrator?, :except => :show

  def index
    @properties = Property.order('code, name')
  end

  def show
    @property = Property.find_by_id(params[:id])
  end

  def new
    @property = Property.new
    @property.cif_form = 'VAE'
  end

  def edit
    unless @property = Property.find_by_id(params[:id])
      flash[:error] = 'I could not find a property with that ID.'
      redirect_to properties_path
    end
  end

  def create
    @property = Property.new(params[:property])

    if @property.save
      flash[:notice] = 'Property was successfully created.'
      redirect_to @property
    else
      flash[:error] = 'There was a problem creating the property.'
      redirect_to new_property_path
    end
  end

  def update
    @property = Property.find_by_id(params[:id])

    if @property and @property.update_attributes(params[:property])
      flash[:notice] = 'Property was successfully updated.'
      redirect_to properties_path
    else
      redirect_to edit_property_path(@property)
    end
  end

  def destroy
    @property = Property.find_by_id(params[:id])
    @property.destroy

    redirect_to properties_path
  end
end