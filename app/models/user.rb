class User < ActiveRecord::Base
  Password = BCrypt::Password

  attr_accessible :email, :password, :password_confirmation, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :work_shifts_attributes

  has_many :tasks,       :dependent => :destroy
  has_many :clients,     :through => :tasks
  has_many :work_shifts, :dependent => :destroy
  has_many :completed_shifts, :through => :tasks

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

  def most_profitable_client

  end

end
















