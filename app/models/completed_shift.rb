class CompletedShift < ActiveRecord::Base
  attr_accessible :duration, :start_date, :task_id
  belongs_to :task
end
