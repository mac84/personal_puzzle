class CompletedShiftsController < ApplicationController

  def new
    @task = current_user.tasks.where(:id => params[:t]).first
    @completed_shift = @task.completed_shifts.new
  end

  def create
    @completed_shift = CompletedShift.new(
      :task_id => params[:task_id],
      :duration => params[:duration],
      :start_date => Time.now - params[:duration].to_i
      )
    @tasks = current_user.tasks.all

    if @completed_shift.save
      @task = Task.find(params[:task_id])

      respond_to do |format|
        format.html
        format.json
      end

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
