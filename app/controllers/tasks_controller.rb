class TasksController < ApplicationController
  def index
    @tasks = current_user.tasks.all
  end

  def new
    @task = current_user.tasks.new
  end

  def create
    @task = current_user.tasks.new(params[:task])

    if @task.save
      redirect_to root_url, :notice => "Jobbet \"" + @task.name + "\" sparat!"
    else
      render "new"
    end
  end

  def show
    @task = Task.find(params[:id])
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
