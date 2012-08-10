class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user

  layout :login_check, :only => [:root]

  private

  def login_check
    if current_user
      layout :render => "tasks/index"
    else
      layout :render => "sessions/new"
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
