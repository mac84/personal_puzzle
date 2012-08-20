# encoding: utf-8
class PasswordResetsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email(params[:email])
    user.send_password_reset if user
    redirect_to root_url, :notice => "Instruktioner om hur du byter lösenord har skickats till e-postadressen du angav."
  end

  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_reset_path, :alert => "Länken gäller inte längre. Prova igen!"
    elsif @user.update_attributes(params[:user])
      redirect_to root_url, :notice => "Ditt nya lösenord är sparat!"
    else
      render :edit
    end
  end
end