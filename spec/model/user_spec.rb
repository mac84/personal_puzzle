require File.dirname(__FILE__) + '/../spec_helper'

describe "User" do
  let(:user) { User.make! }

  describe "validations" do
    it "can be valid" do
      User.make.should be_valid
    end
  end

  describe "saving a user" do
    it "generates password salt and hash if password is set" do
      user = User.make(:password => "1234")
      user.password_hash.should eq(nil)
      user.save

      user.password_hash.should eq(BCrypt::Engine.hash_secret(user.password, user.password_salt))
    end

    it "does not generate a password salt and hash if password is not set" do
      user = User.make(:password => nil)
      expect { user.save }.to_not change { user.password_hash }
    end
  end

  describe ".authenticate" do
    it "returns nothing if no user is found" do
      email = "hej@hej.se"
      password = "1234"
      User.authenticate(email, password).should eq(nil)
    end

    it "returns user if user with the given password is found" do
      email = "hej@hej.se"
      password = "1234"
      user = User.make!(:email => email, :password => password)
      User.authenticate(email, password).should eq(user)
    end

    it "returns nothing if wrong password is given" do
      email = "hej@hej.se"
      password = "1234"
      user = User.make!(:email => email, :password => password)
      User.authenticate(email, "wrong_password").should eq(nil)
    end
  end
end