class WorkShift < ActiveRecord::Base
  attr_accessible :duration, :start_time, :user_id
  belongs_to :user
end
