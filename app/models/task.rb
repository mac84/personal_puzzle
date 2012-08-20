class Task < ActiveRecord::Base
  attr_accessible :date_finished, :deadline_date, :fee, :hourly_rate, :name, :client_id

  belongs_to :user
  belongs_to :client
  has_many :completed_shifts

  validates_presence_of :name

  default_scope :order => 'deadline_date ASC'
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
end
