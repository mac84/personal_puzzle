# encoding: utf-8
class User < ActiveRecord::Base
  Password = BCrypt::Password

  attr_accessible :email, :password, :password_confirmation, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :min_scheduled_shift_length, :work_shifts_attributes

  has_many :tasks,       :dependent => :destroy
  has_many :clients
  has_many :work_shifts, :dependent => :destroy
  has_many :completed_shifts, :through => :tasks
  has_many :scheduled_shifts, :through => :tasks

  accepts_nested_attributes_for :work_shifts, :allow_destroy => true

  validates_confirmation_of :password, :on => :create
  validates_presence_of     :password, :on => :create
  validates :email, :presence => true,
                    :uniqueness => true,
                    :format => {:with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/}

  before_create { generate_token(:auth_token) }

  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password == password
      true
    else
      false
    end
  end

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    return if new_password.blank?
    @password = Password.create(new_password, :cost => Rails.application.config.bcrypt_cost)
    self.password_hash = @password
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def clear_schedule
    ScheduledShift.where(:task_id => self.task_ids).delete_all
  end

  def daily_worktime
    work_hours_in_a_day = 0
    self.work_shifts.each do |ws|
      work_hours_in_a_day += ws.duration
    end
    work_hours_in_a_day
  end

  def weekly_worktime
    beginning_of_week = Time.now.beginning_of_week
    end_of_week = Time.now.end_of_week
    work_days = work_days_between(beginning_of_week, end_of_week)
    work_hours_in_a_week = work_days * daily_worktime
  end

  def monthly_worktime(month=Time.now.strftime("%B"))
    month_as_date = Date.strptime(month, "%B")
    work_days = work_days_between(month_as_date.beginning_of_month, month_as_date.end_of_month)
    work_hours_in_a_month = work_days * daily_worktime
  end

  def work_days_between(date1, date2)
    work_days = 0
    date = date2
    while date > date1
     work_days = work_days + 1 if self.works_on(date)
     date = date - 1.day
    end
    work_days
  end

  def work_hours_between(date1, date2)
    work_days = work_days_between(date1, date2)
    work_hours = work_days * daily_worktime
  end

  def works_on(day)
    send "#{day.strftime("%A").downcase}?"
  end

  def worked_hours_between(date1, date2)
    worked_hours = 0
    worked_shifts = self.completed_shifts.where(:start_date => date1..date2) if self.completed_shifts

    worked_shifts.each do |ws|
      worked_hours += ws.duration
    end
    worked_hours
  end

  def utilization_between(date1, date2)
    worked_hours = worked_hours_between(date1, date2)
    work_hours = work_hours_between(date1, date2)

    if worked_hours > 0 && work_hours >0
      utilization = ((worked_hours.to_f / work_hours) * 100).round
    else
      utilization = 0
    end
    utilization
  end

  def number_of_tasks_for(client)
    self.tasks.where(:client_id => client.id).size
  end

  def has_any_completed_tasks?
    self.tasks.where("date_finished is NOT NULL").size > 0
  end

  def most_profitable_client
    if self.tasks.where("date_finished is NOT NULL").size > 0
      clients_and_their_hourly_pay = Hash.new(0)

      number_of_finished_tasks_per_client.each_with_index do |n, i|
        clients_and_their_hourly_pay[n[0][0]] = accumulated_hourly_pay[[n[0][0]]].to_f / number_of_finished_tasks_per_client[[n[0][0]]]
      end

      clients_and_their_hourly_pay.sort_by {|keys, values| values}.reverse
      # Client.find_by_name(clients_and_their_hourly_pay.max[0]) if !clients_and_their_hourly_pay.empty?
    else
      error = "Inga slutförda jobb ännu!"
    end
  end

  def most_worked_for_client
    if self.tasks.where("date_finished is NOT NULL").size > 0
      clients_and_the_hours_spent_on_them = Hash.new(0)

      number_of_finished_tasks_per_client.each_with_index do |n, i|
        clients_and_the_hours_spent_on_them[n[0][0]] = accumulated_work_hours[[n[0][0]]]
      end

      clients_and_the_hours_spent_on_them.sort_by {|keys, values| values}.reverse
      # Client.find_by_name(clients_and_their_hourly_pay.max[0]) if !clients_and_their_hourly_pay.empty?
    else
      error = "Inga slutförda jobb ännu!"
    end
  end

  def accumulated_hourly_pay
    self.tasks.where("date_finished is NOT NULL").each_with_object(Hash.new(0)) do |ft, result|
      result[[ft.client_name]] += ft.hourly_pay
    end
  end

  def accumulated_work_hours
    self.tasks.where("date_finished is NOT NULL").each_with_object(Hash.new(0)) do |ft, result|
      result[[ft.client_name]] += ft.worked_time
    end
  end

  def number_of_finished_tasks_per_client
    self.tasks.where("date_finished is NOT NULL").each_with_object(Hash.new(0)) do |ft, result|
      result[[ft.client_name]] += 1
    end
  end

  def schedule
    active_tasks = self.tasks.where(:date_finished => nil, :archived => false).order("deadline_date")

    active_tasks.each do |task_to_schedule|
      task_duration = ((task_to_schedule.fee.to_f / task_to_schedule.hourly_rate).ceil) - completed_shifts_duration(task_to_schedule)
      today = Time.now
      puts today
      # puts today.to_datetime
      start_date = today.beginning_of_hour + 1.hour
      puts start_date

      while task_duration > 0
        if self.works_on(today) && (unscheduled_work_time_left(today + (last_scheduled_shift_end_time(today) * 1.minute)) >= (self.min_scheduled_shift_length * 1.minute))

          start_date += ((last_scheduled_shift_end_time(today) - (start_date.hour * 60)) * 60) if any_scheduled_shifts(today)

          if work_shift_has_started(start_date, closest_work_shift_from(today)) && ((end_time_for(closest_work_shift_from(today)) - start_date.hour) < self.min_scheduled_shift_length)
            next_work_shift = closest_work_shift_from(start_date + (((end_time_for(closest_work_shift_from(start_date))) * 1.hour) - (start_date.hour * 3600)))
            start_date += ((next_work_shift.start_time.hour + (next_work_shift.start_time.min.to_f / 60)) - start_date.hour) * 3600
            puts start_date
          end

          task_to_schedule.scheduled_shifts.create(:start_date => (start_date), :duration => scheduled_shift_duration(task_duration))

          task_duration -= scheduled_shift_duration(task_duration)
          today += 1.day
          today = today.beginning_of_day
          start_date = today
          first_work_shift = self.work_shifts.order(:start_time).first
          start_date += ((first_work_shift.start_time.hour * 3600) + (first_work_shift.start_time.min * 60))
        else
          today += 1.day
          today = today.beginning_of_day
          start_date = today
          first_work_shift = self.work_shifts.order(:start_time).first
          start_date += ((first_work_shift.start_time.hour * 3600) + (first_work_shift.start_time.min * 60))
        end

      end
      # puts self.scheduled_shifts.all.inspect
    end

  end

  def closest_work_shift_from(now)
    self.work_shifts.order("start_time").detect { |shift| (shift.start_time.hour * 60) + shift.start_time.min + (shift.duration * 60) > ((now.hour * 60) + now.min) }
  end

  def completed_shifts_duration(task)
    total_duration = 0
    task.completed_shifts.each do |cs|
      total_duration += cs.duration
    end
    total_duration
  end

  def last_scheduled_shift(today)
    self.scheduled_shifts.where("start_date between ? and ?", today.beginning_of_day, today.end_of_day).order(:start_date).last
  end

  def last_scheduled_shift_end_time(today) # Kan rationaliseras bort och ersättas med en kombination av last_sched och end_time_for
    if self.scheduled_shifts.where("start_date between ? and ?", (today.beginning_of_day + today.gmt_offset), (today.end_of_day + today.gmt_offset)).size > 0
      last_scheduled_shift_today = self.scheduled_shifts.where("start_date between ? and ?", today.beginning_of_day, today.end_of_day).order(:start_date).last
      last_scheduled_shift_today_end_time = last_scheduled_shift_today.start_date + (last_scheduled_shift_today.duration * 3600)
      last_scheduled_shift_today_end_time.min + (last_scheduled_shift_today_end_time.hour * 60)
    else
      0
    end
  end

  def any_scheduled_shifts(today)
    self.scheduled_shifts.where("start_date between ? and ?", (today.beginning_of_day + today.gmt_offset), (today.end_of_day + today.gmt_offset)).size > 0
  end

  def unscheduled_work_time_left(today)
    if any_scheduled_shifts(today)
      work_time_left(today) - last_scheduled_shift_end_time(today)
    else
      work_time_left(today)
    end
  end

  def work_time_left(today)
    last_work_shift_today = self.work_shifts.order("start_time").last
    end_of_last_work_shift_today = last_work_shift_today.start_time + (last_work_shift_today.duration * 3600)

    end_of_last_work_shift_today_in_hours = ((end_of_last_work_shift_today.min.to_f / 60) + end_of_last_work_shift_today.hour)

    start_of_next_hour = today.beginning_of_hour + 1.hour

    work_shifts_left_today = self.work_shifts.order("start_time").find_all { |shift| (shift.start_time.hour * 60) + shift.start_time.min + (shift.duration * 60) > (start_of_next_hour.hour * 60) }
    closest_work_shift_from_now = work_shifts_left_today.first

    if start_of_next_hour.hour < end_of_last_work_shift_today_in_hours

      if work_shift_has_started(start_of_next_hour, closest_work_shift_from_now)
        elapsed_worktime_of_closest_work_shift = closest_work_shift_from_now.duration - (end_time_for(closest_work_shift_from_now) - start_of_next_hour.hour)

        (closest_work_shift_from_now.duration - elapsed_worktime_of_closest_work_shift + remaining_work_shift_duration(work_shifts_left_today)) * 60
      else
        (closest_work_shift_from_now.duration + remaining_work_shift_duration(work_shifts_left_today)) * 60
      end
    else
      0
    end
  end

  def work_shift_has_started(now, closest_work_shift_from_now)
    now.hour > closest_work_shift_from_now.start_time.hour && now.hour < end_time_for(closest_work_shift_from_now)
  end

  def end_time_for(shift)
    ((shift.start_time.hour * 60) + shift.start_time.min + (shift.duration * 60)).to_f / 60
  end

  def remaining_work_shift_duration(work_shifts_left_today)
    remaining_work_shift_duration = 0
    work_shifts_left_today.each_with_index do |ws, i|
      remaining_work_shift_duration += ws.duration if i > 0
    end
    remaining_work_shift_duration
  end

  def scheduled_shift_duration(task_duration)
    if task_duration >= self.min_scheduled_shift_length
      self.min_scheduled_shift_length
    else
      task_duration
    end
  end

  def schedule_up_to_date?
    latest_scheduled_shift = self.scheduled_shifts.order("created_at DESC").first
    latest_completed_shift = self.completed_shifts.order("created_at DESC").first

    if latest_scheduled_shift && latest_completed_shift
      latest_completed_shift.created_at < latest_scheduled_shift.created_at
    else
      false
    end
  end

end
















