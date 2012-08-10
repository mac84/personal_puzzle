class ClientsController < ApplicationController
  def index
    @clients = current_user.clients.all
  end

  def new
    @client = current_user.clients.new
  end

  def create
    @client = Client.new(params[:client])

    if @client.save
      redirect_to root_url, :notice => "Uppdragsgivaren \"" + @client.name + "\" sparat!"
    else
      render "new"
    end
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
