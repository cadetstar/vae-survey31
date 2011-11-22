class ClientsController < ApplicationController
  def index
    setup_session_defaults_for_controller(:client, :last_name)

    @clients = build_query(Client, :client)
  end

  def new
    unless company = Company.find_by_id(params[:company_id])
      flash[:error] = 'You must supply a company to create a client for.'
      redirect_to companies_path
      return
    end
    unless current_user.admin? or current_user.all_properties.include? company.property
      flash[:error] = 'You do not have permission to create clients for that company.'
      redirect_to clients_path
      return
    end
    @client = Client.create(:company_id => company.id, :property_id => company.property_id)
    redirect_to edit_client_path(@client)
  end

  def edit
    unless @client = Client.find_by_id(params[:id])
      flash[:error] = 'I could not find a client with that ID.'
      redirect_to clients_path
    end
  end

  def update
    unless @client = Client.find_by_id(params[:id])
      flash[:error] = 'I could not find a client with that ID.'
      redirect_to clients_path
    end

    if @client.update_attributes(params[:client])
      flash[:notice] = 'Client updated.'
      redirect_to @client
    else
      flash[:error] = 'There was a problem updating the client.'
      redirect_to edit_client_path(@client)
    end
  end

  def show
    unless @client = Client.find_by_id(params[:id])
      flash[:error] = 'I could not find a client with that ID.'
      redirect_to clients_path
    end
  end

  def destroy
    unless @client = Client.find_by_id(params[:id])
      flash[:error] = 'I could not find a client with that ID.'
    else
      flash[:notice] = "Client #{@client} destroyed."
      @client.destroy
    end
    redirect_to clients_path
  end
end