class User < ActiveRecord::Base
  Password = BCrypt::Password

  attr_accessible :email, :password, :password_confirmation

  has_many :tasks, :dependent => :destroy
  has_many :clients, :through => :tasks

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates :email, :presence => true,
                    :uniqueness => true,
                    :format => {:with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/}


  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password == password
      user
    else
      nil
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
end

