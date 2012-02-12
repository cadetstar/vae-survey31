class ThankYouCardsController < ApplicationController
  before_filter :authenticate_user!, :except => [:view, :destroy]

  def index
    session[:thank_you_cards] ||= {}
    session[:thank_you_cards][:restrict] ||= 'awaiting'
    session[:thank_you_cards][:scope] ||= 'all'

    session[:thank_you_cards][:page] ||= 1

    if params[:restrict] and %w(awaiting sent all).include? params[:restrict]
      session[:thank_you_cards][:restrict] = params[:restrict]
    end

    if params[:scope] and %w(all mine subord subandmine).include? params[:scope]
      session[:thank_you_cards][:scope] = params[:scope]
    end

    if params[:page]
      session[:thank_you_cards][:page] = params[:page].to_i
    end

    @thank_you_cards = ThankYouCard.order("sent_at, thank_you_cards.updated_at").joins(:prop_season)
    case session[:thank_you_cards][:restrict]
      when 'awaiting'
        @thank_you_cards = @thank_you_cards.where('sent_at is null')
      when 'sent'
        @thank_you_cards = @thank_you_cards.where('sent_at is not null')
    end

    case session[:thank_you_cards][:scope]
      when 'mine'
        @thank_you_cards = @thank_you_cards.where(['property_id in (?)', current_user.my_properties.collect{|r| r.id}])
      when 'subord'
        @thank_you_cards = @thank_you_cards.where(['property_id in (?)', current_user.all_supervised_properties.collect{|r| r.id}])
      when 'subandmine'
        @thank_you_cards = @thank_you_cards.where(['property_id in (?)', current_user.all_properties.collect{|r| r.id}])
    end

    if session[:thank_you_cards][:page] > 1 and (session[:thank_you_cards][:page] - 1) * ApplicationController::RECORDS_PER_PAGE > @thank_you_cards.size
      session[:thank_you_cards][:page] = 1
    end
    @thank_you_cards = @thank_you_cards.page(session[:thank_you_cards][:page])
  end

  def new
    unless @client = Client.find_by_id(params[:client_id])
      flash[:error] = 'You need to supply a client to make a thank you card for.'
      redirect_to clients_path
      return
    end

    unless current_user.admin? or current_user.all_properties.include? @client.property
      flash[:error] = 'You cannot create thank you cards for that client.'
      redirect_to clients_path
      return
    end

    if ps = PropSeason.find_by_id(params[:property])
      @thank_you_card = ThankYouCard.create(:client_id => @client.id, :cif_id => params[:cif], :prop_season_id => ps.id)
      if @cif = Cif.find_by_id(params[:cif_id])
        @cif.update_attribute(:thank_you_card_id, @thank_you_card.id)
      end
      redirect_to edit_thank_you_card_path(@thank_you_card)
    else
      @thank_you_card = ThankYouCard.new(:client_id => @client.id)
    end
  end

  def create
    if tyc = ThankYouCard.create(params[:thank_you_card])
      flash[:notice] = 'Thank you card created.'
      redirect_to view_tyc_path(:id => tyc.id, :passcode => tyc.passcode)
    else
      flash[:error] = 'There was an error creating the card.'
      redirect_to clients_path
    end
  end

  def edit
    unless @thank_you_card = ThankYouCard.find_by_id(params[:id])
      flash[:error] = 'I could not find a thank you card with that ID.'
      redirect_to thank_you_cards_path
    end
  end

  def update
    unless @thank_you_card = ThankYouCard.find_by_id(params[:id])
      flash[:error] = 'I could not find a thank you card with that ID.'
    else
      if @thank_you_card.update_attributes(params[:thank_you_card])
        flash[:notice] = 'Thank You Card updated.'
        redirect_to view_tyc_path(:id => @thank_you_card.id, :passcode => @thank_you_card.passcode)
        return
      else
        flash[:error] = 'There was an error updating the card.'
        redirect_to edit_thank_you_card_path(@thank_you_card)
        return
      end
    end
    redirect_to thank_you_cards_path
  end

  def destroy
    unless @thank_you_card = ThankYouCard.find_by_id(params[:id])
      flash[:error] = 'I could not find a thank you card with that ID.'
    else
      if current_user.admin? or current_user.all_properties.include? @thank_you_card.property
        flash[:notice] = 'Thank You Card destroyed.'
        @thank_you_card.destroy
      end
    end

    redirect_to thank_you_cards_path
  end

  def view
    unless @thank_you_card = ThankYouCard.find_by_id(params[:id])
      render :text => "I could not find that thank you card.", :layout => false
    else
      unless @thank_you_card.passcode == params[:passcode]
        render :text => "I could not find that thank you card.", :layout => false
      else
        render :layout => false
      end
    end
  end
end