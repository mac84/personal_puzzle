
class Task < ActiveRecord::Base
  attr_accessible :date_finished, :deadline_date, :fee, :hourly_rate, :name, :client_id

  belongs_to :user
  belongs_to :client

  validates_presence_of :name

  default_scope :order => 'deadline_date ASC'
  delegate :name, :to => :client, :prefix => true

end
