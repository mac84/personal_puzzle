class ScheduledShiftsController < ApplicationController
  def index
    @scheduled_shifts = current_user.scheduled_shifts.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @scheduled_shifts }
    end
  end

  def show
    @scheduled_shift = ScheduledShift.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @scheduled_shift }
    end
  end

  def new
    @scheduled_shift = ScheduledShift.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @scheduled_shift }
    end
  end

  def edit
    @scheduled_shift = ScheduledShift.find(params[:id])
  end

  def create
    @scheduled_shift = ScheduledShift.new(params[:scheduled_shift])

    respond_to do |format|
      if @scheduled_shift.save
        format.html { redirect_to @scheduled_shift, notice: 'Scheduled shift was successfully created.' }
        format.json { render json: @scheduled_shift, status: :created, location: @scheduled_shift }
      else
        format.html { render action: "new" }
        format.json { render json: @scheduled_shift.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @scheduled_shift = ScheduledShift.find(params[:id])

    respond_to do |format|
      if @scheduled_shift.update_attributes(params[:scheduled_shift])
        format.html { redirect_to @scheduled_shift, notice: 'Scheduled shift was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @scheduled_shift.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @scheduled_shift = ScheduledShift.find(params[:id])
    @scheduled_shift.destroy

    respond_to do |format|
      format.html { redirect_to scheduled_shifts_url }
      format.json { head :no_content }
    end
  end
end
