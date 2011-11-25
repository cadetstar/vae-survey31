class SeasonsController < ApplicationController
  before_filter :is_administrator?

  def index
    @seasons = Season.order(:name)
  end

  def new
    @season = Season.create(:name => "Temporary Name - Please change me!")
    redirect_to edit_season_path(@season)
  end

  def edit
    unless @season = Season.find_by_id(params[:id])
      flash[:error] = 'I could not find a season with that ID.'
      redirect_to seasons_path
    end
  end

  def update
    unless @season = Season.find_by_id(params[:id])
      flash[:error] = 'I could not find a season with that ID.'
      redirect_to seasons_path
      return
    end

    if @season.update_attributes(params[:season])
      flash[:notice] = 'Season updated.'
      redirect_to @season
    else
      flash[:error] = 'There was an error updating the season.'
      redirect_to edit_season_path(@season)
    end
  end

  def destroy
    unless @season = Season.find_by_id(params[:id])
      flash[:error] = 'I could not find a season with that ID.'
    else
      if @season.destroy
        flash[:notice] = 'Season destroyed.'
      else
        flash[:error] = 'I was unable to destroy the season, it probably has thank you cards attached.'
      end
    end

    redirect_to seasons_path
  end

  def enable
    unless @season = Season.find_by_id(params[:id])
      flash[:error] = 'I could not find a season with that ID.'
    else
      if @season.enabled
        flash[:error] = 'That season is already enabled.'
      else
        @season.update_attribute(:enabled, true)
        flash[:notice] = "Season #{@season} is now enabled."
      end
    end

    redirect_to seasons_path
  end

  def disable
    unless @season = Season.find_by_id(params[:id])
      flash[:error] = 'I could not find a season with that ID.'
    else
      unless @season.enabled
        flash[:error] = 'That season is already disabled.'
      else
        @season.update_attribute(:enabled, false)
        flash[:notice] = "Season #{@season} is now disabled."
      end
    end

    redirect_to seasons_path
  end

  def send_season
    unless @season = Season.find_by_id(params[:id])
      flash[:error] = 'I could not find a season with that ID.'
    else
      @season.update_attribute(:when_email, 2.hours.ago)
      flash[:notice] = "Season #{@season} is now set to send all emails updated before #{@season.when_email.to_s(:date_time12)}."
    end

    redirect_to seasons_path
  end
end