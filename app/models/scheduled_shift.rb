class ScheduledShift < ActiveRecord::Base
  attr_accessible :duration, :start_date, :task_id

  belongs_to :task

  delegate :name, :to => :task, :prefix => true, :allow_nil => true

end
