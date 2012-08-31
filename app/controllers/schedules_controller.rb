class SchedulesController < ApplicationController
  def index
    @scheduled_shifts = current_user.scheduled_shifts.order("start_date DESC")
    last_scheduled_shift = current_user.scheduled_shifts.order("start_date DESC").first
    @last_ss_date = last_scheduled_shift.try :start_date

    @view_type = params[:view_type] || "week"

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def new
    @user = current_user
    @user.clear_schedule
    @user.schedule

    redirect_to schedules_path, :notice => "Schemat uppdaterat!"
  end

  def destroy
  end
end
