class CompletedShiftsController < ApplicationController

  def create
    @completed_shift = CompletedShift.new(
      :task_id => params[:task_id],
      :duration => params[:duration],
      :start_date => Time.now - params[:duration].to_i
      )
    @tasks = current_user.tasks.all

    if @completed_shift.save
      worked_percentage = Task.find(params[:task_id]).worked_percentage
      render :json => worked_percentage
    else
      nil
    end
  end

  def destroy
    @completed_shift = CompletedShift.find(params[:id])
    @task = Task.find(@completed_shift.task_id)

    if @completed_shift.destroy
      redirect_to task_path(@task), :notice => "Passet borttaget!"
    else
      nil
    end
  end
end
