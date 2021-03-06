class Task < ActiveRecord::Base
  attr_accessible :date_finished, :deadline_date, :fee, :hourly_rate, :name, :client_id, :archived, :completed_shifts_attributes

  belongs_to :user
  belongs_to :client
  has_many :completed_shifts, :dependent => :destroy
  has_many :scheduled_shifts, :dependent => :destroy

  accepts_nested_attributes_for :completed_shifts

  validates_presence_of :name

  # default_scope :order => 'deadline_date ASC' # Applies to ALL calls to task model, even completed_shifts/scheduled_shifts
  delegate :name, :to => :client, :prefix => true, :allow_nil => true

  def worked_time
    worked_time = 0
    self.completed_shifts.each do |cs|
      worked_time += cs.duration
    end
    worked_time
  end

  def work_time
    work_time = (self.fee.to_f / self.hourly_rate.to_f) * 3600
  end

  def worked_percentage
    worked_percentage = ((self.worked_time / self.work_time) * 100).round
  end

  def hourly_pay
    if worked_time > 0
      self.fee / worked_time.to_f
    else
      self.hourly_rate # Warning! This is a fallback if a task is marked as completed without any completed shifts.
    end
  end


end
