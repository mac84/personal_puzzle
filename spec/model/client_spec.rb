require File.dirname(__FILE__) + '/../spec_helper'

describe "Client" do
  let(:Client) { Client.make! }

  describe "validations" do
    it "can be valid" do
      Client.make.should be_valid
    end
  end

end