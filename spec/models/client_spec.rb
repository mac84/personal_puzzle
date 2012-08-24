describe "Client" do
  let(:client) { Client.make }
  let(:user) { User.make }

  describe "validations" do
    it "can be valid" do
      Client.make.should be_valid
    end

    it "validates presence of name on create" do
      client.should_not allow(nil, "", " ").as(:name)
    end

    it "does not allow negative standard rate" do
      client.should_not allow(-1).as(:standard_rate)
    end

    it "allows a standard rate of 0 or more" do
      client.should allow(0, 1, 1000).as(:standard_rate)
    end
  end
end
