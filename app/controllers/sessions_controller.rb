# encoding: utf-8
class SessionsController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create]

  def new
  end

  def create
    user = User.find_by_email(params[:email])
    if user && User.authenticate(params[:email], params[:password])
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end
      redirect_to root_url, :notice => "Välkommen " + user.email + "!"
    else
      flash.now.alert = "Felaktigt användarnamn eller lösenord"
      render "new"
    end
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to root_url, :notice => "Utloggad!"
  end
end