class Client < ActiveRecord::Base
  attr_accessible :name, :standard_rate, :tasks_attributes
  has_many :tasks
  accepts_nested_attributes_for :tasks

  validates_presence_of :name
  validates_numericality_of :standard_rate, :greater_than_or_equal_to => 0, :allow_nil => true
end
