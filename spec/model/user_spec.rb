describe "User" do
  let(:user) { User.make }

  describe "validations" do
    it "can be valid" do
      User.make.should be_valid
    end

    it "validates confirmation of password" do
      user = User.make(:password =>"1234", :password_confirmation =>"wrong")
      user.should have(1).error_on(:password)
    end

    it "validates presence of password on create" do
      user = User.make(:password => nil)
      expect { user.save! }.to raise_error{ActiveRecord::RecordInvalid}
    end

    it "validates format of email" do
      user.should_not allow(nil, "", "foo", "foo@bar").as(:email)
      user.should allow("foo@bar.com").as(:email)
    end

    it "validates uniqueness of email" do
      user1 = User.make!(:email => "foo@bar.com")
      user2 = User.make(:email => "foo@bar.com")
      user2.should have(1).error_on(:email)
    end
  end

  describe "#password" do
    it "hashes the password when set" do
      user = User.make(:password => "1234")
      user.password.should eq("1234")
      user.password.to_s.should_not eq("1234")
    end

    it "should not equal another password" do
      user = User.make(:password => "1234")
      user.password.should_not eq("not my password")
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
