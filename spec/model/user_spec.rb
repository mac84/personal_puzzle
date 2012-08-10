require File.dirname(__FILE__) + '/../spec_helper'

describe "User" do
  let(:user) { User.make! }

  describe "validations" do
    it "can be valid" do
      User.make.should be_valid
    end
  end

end