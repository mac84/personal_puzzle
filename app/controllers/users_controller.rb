# encoding: utf-8
class UsersController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create]
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      session[:user_id] = user.id
      cookies[:auth_token] = user.auth_token
      redirect_to root_url, :notice => "Användare skapad! Välkommen!"
    else
      render "new"
    end
  end
end
