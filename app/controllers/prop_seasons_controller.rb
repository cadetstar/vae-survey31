class PropSeasonsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @prop_seasons = PropSeason.joins(:property, :season).order("seasons.enabled desc, properties.code, seasons.name")

    unless current_user.admin?
      @prop_seasons = @prop_seasons.where(['property_id in (?)', current_user.all_properties.collect{|r| r.id}]).where(:seasons => {:enabled => true})
    end
  end

  def edit
    unless @prop_season = PropSeason.find_by_id(params[:id])
      flash[:error] = 'I could not find a property_season with that ID.'
      redirect_to prop_seasons_path
    end

    unless current_user.admin? or current_user.all_properties.include? @prop_season.property
      flash[:error] = 'You cannot edit that template.'
      redirect_to prop_seasons_path
    end
  end

  def update
    unless @prop_season = PropSeason.find_by_id(params[:id])
      flash[:error] = 'I could not find a property_season with that ID.'
      redirect_to prop_seasons_path
      return
    end

    unless current_user.admin? or current_user.all_properties.include? @prop_season.property
      flash[:error] = 'You cannot edit that template.'
      redirect_to prop_seasons_path
      return
    end


    if @prop_season.update_attributes(params[:prop_season])
      flash[:notice] = 'Template Updated.'
      redirect_to prop_seasons_path
    else
      flash[:error] = 'There was an error saving the template.'
      redirect_to edit_prop_season_path(@prop_season)
    end
  end

  def show
    unless @prop_season = PropSeason.find_by_id(params[:id])
      flash[:error] = 'I could not find a property_season with that ID.'
      redirect_to prop_seasons_path
      return
    end

    unless current_user.admin? or current_user.all_properties.include?(@prop_season.property)
      flash[:error] = 'You are not eligible to view that template.'
      redirect_to prop_seasons_path
    end
  end
end