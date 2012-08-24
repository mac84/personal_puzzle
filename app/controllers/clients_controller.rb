class ClientsController < ApplicationController
  def index
    @clients = current_user.clients.all
  end

  def new
    @client = current_user.clients.new
  end

  def create
    @client = current_user.clients.new(params[:client])

    if @client.save
      redirect_to clients_url, :notice => "Uppdragsgivaren \"" + @client.name + "\" sparad!"
    else
      render "new"
    end
  end

  def show
    @client = Client.find(params[:id])
  end

  def edit
    @client = Client.find(params[:id])
  end

  def update
    @client = Client.find(params[:id])
    if @client.update_attributes(params[:client])
      redirect_to root_url, :notice => "Uppdragsgivaren \"" + @client.name + "\" uppdaterad!"
    else
      render "edit"
    end
  end

  def destroy
  end
end
