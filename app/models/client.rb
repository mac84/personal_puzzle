class Client < ActiveRecord::Base
  attr_accessible :name, :standard_rate
  has_many :tasks
  validates_presence_of :name
  validates_numericality_of :standard_rate, :greater_than_or_equal_to => 0, :allow_nil => true
end
