# encoding: utf-8
class UsersController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create]

  def new
    @user = User.new
  end

  def show
    @user = current_user
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to user_path(@user), :notice => "Användaren uppdaterad!"
    else
      render "edit"
    end
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      cookies[:auth_token] = user.auth_token
      redirect_to root_url, :notice => "Användare skapad! Välkommen!"
    else
      render "new"
    end
  end
end
