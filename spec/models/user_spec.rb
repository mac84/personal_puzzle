# encoding: utf-8
describe "User" do
  let(:user) { User.make }
  let(:task) { Task.make }
  let(:client) { Client.make }

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
      User.authenticate(email, password).should eq(false)
    end

    it "returns true if user with the given password is found" do
      email = "hej@hej.se"
      password = "1234"
      user = User.make!(:email => email, :password => password)
      User.authenticate(email, password).should eq(true)
    end

    it "returns nothing if wrong password is given" do
      email = "hej@hej.se"
      password = "1234"
      user = User.make!(:email => email, :password => password)
      User.authenticate(email, "wrong_password").should eq(false)
    end
  end

  describe "#monthly_worktime" do
    it "returns zero if user has not defined any worktime" do
      user.monthly_worktime(Time.now.strftime("%B")).should eq(0)
    end

    it "returns the monthly worktime in hours if a worktime is set" do
      user.work_shifts.new(:start_time => Time.now, :duration => 2)
      user.monday = true
      current_month = "august"

      user.save
      user.monthly_worktime(current_month).should eq(8)
    end
  end

  describe "#weekly_worktime" do
    it "returns zero if user has not defined any worktime" do
      user.weekly_worktime.should eq(0)
    end

    it "returns the weekly worktime in hours if a worktime is set" do
      user.work_shifts.new(:start_time => Time.now, :duration => 2)
      user.monday = true
      user.tuesday = true
      user.thursday = true

      user.save
      user.weekly_worktime.should eq(6)
    end
  end

  describe "#utilization_between" do
    it "returns zero if user has not defined any worktime" do
      user.utilization_between(7.days.ago, Time.now).should eq(0)
    end

    it "returns the utilization in rounded percentage if a worktime is set and work shifts has been completed" do
      client1 = Client.make!(:user => user)
      task1 = Task.make!(:client => client1, :user => user)

      task1.completed_shifts.new(:start_date => 1.day.ago, :duration => 2)
      task1.completed_shifts.new(:start_date => 2.days.ago, :duration => 2)
      task1.save

      user.work_shifts.new(:start_time => Time.now, :duration => 2)
      user.work_shifts.new(:start_time => 3.hours.ago, :duration => 2)
      user.monday = true
      user.tuesday = true
      user.thursday = true
      user.save

      # A total of 4 hours * 3 days = 12 hours/week in work-time
      # A total of 4 hours in completed work shifts last 7 days

      user.utilization_between(7.days.ago, Time.now).should eq(33)
    end
  end

  describe "#most_profitable_client" do
    before do
      @client1 = Client.make!(:user => user)
      @client2 = Client.make!(:user => user)
      @client3 = Client.make!(:user => user)
      @task1 = Task.make!(:client => @client1, :user => user, :hourly_rate => '100', :fee => '1000')
      @task2 = Task.make!(:client => @client2, :user => user, :hourly_rate => '200', :fee => '3000')
      @task3 = Task.make!(:client => @client3, :user => user, :hourly_rate => '300', :fee => '4000')
      @task4 = Task.make!(:client => @client3, :user => user, :hourly_rate => '300', :fee => '2000')

      cs1 = CompletedShift.make!(:start_date => 1.day.ago,  :duration => 2, :task_id => @task1.id)
      cs2 = CompletedShift.make!(:start_date => 2.days.ago, :duration => 2, :task_id => @task1.id)
      cs3 = CompletedShift.make!(:start_date => 3.days.ago, :duration => 2, :task_id => @task2.id)
      cs4 = CompletedShift.make!(:start_date => 4.days.ago, :duration => 2, :task_id => @task2.id)
      cs5 = CompletedShift.make!(:start_date => 5.days.ago, :duration => 2, :task_id => @task3.id)
      cs6 = CompletedShift.make!(:start_date => 5.days.ago, :duration => 4, :task_id => @task4.id)
    end

    it "returns nothing if no task is finished" do
      error = "Inga slutförda jobb ännu!"
      user.most_profitable_client.should eq(error)
    end

    it "returns only one client if one task is finished, that task's client" do
      @task1.update_column('date_finished', DateTime.now)
      @task1.save
      user.most_profitable_client.should include(@client1)
    end

    it "returns the most profitable client if more than one task is finished", :pending => :true do
      @task1.update_column('date_finished', DateTime.now)
      @task2.update_column('date_finished', DateTime.now)
      @task3.update_column('date_finished', DateTime.now)
      @task4.update_column('date_finished', DateTime.now)
      @task1.save
      @task2.save
      @task3.save
      @task4.save
      user.most_profitable_client.should eq(@client3)
    end
  end

  describe "#schedule" do
    after(:each) { back_to_the_present } #Or back_to_1985 :)
    before do
      today    = Time.parse("10-04-2009 10:00 UTC").strftime("%A").downcase
      tomorrow = Time.parse("11-04-2009 10:00 UTC").strftime("%A").downcase
      @now = Time.parse("10-04-2009 10:00 UTC")
      @user2 = User.make!(:min_scheduled_shift_length => 2, :"#{today}" => true, :"#{tomorrow}" => true)
      @ws0 = WorkShift.make!(:start_time => Time.parse("10-04-2009 06:30 UTC"), :duration => 2, :user_id => @user2.id)
      @ws1 = WorkShift.make!(:start_time => Time.parse("10-04-2009 09:30 UTC"), :duration => 2, :user_id => @user2.id)
      @ws2 = WorkShift.make!(:start_time => Time.parse("10-04-2009 13:00 UTC"), :duration => 2, :user_id => @user2.id)
      # @ws3 = WorkShift.make!(:start_time => Time.parse("10-04-2009 16:10 UTC"), :duration => 3, :user_id => @user2.id)
      @client1 = Client.make!(:user => @user2)
      @client2 = Client.make!(:user => @user2)
      @client3 = Client.make!(:user => @user2)
      @task1 = Task.make!(:client => @client1, :user => @user2, :hourly_rate => '100', :fee => '1000', :deadline_date => Time.parse("10-04-2009 10:00 UTC") + 10.days)
      # @task2 = Task.make!(:client => @client2, :user => @user2, :hourly_rate => '200', :fee => '3000', :deadline_date => Time.parse("10-04-2009 10:00 UTC") + 40.days)
      # @task3 = Task.make!(:client => @client3, :user => @user2, :hourly_rate => '300', :fee => '4000', :deadline_date => Time.parse("10-04-2009 10:00 UTC") + 30.days)
      # @task4 = Task.make!(:client => @client3, :user => @user2, :hourly_rate => '300', :fee => '2000', :deadline_date => Time.parse("10-04-2009 10:00 UTC") + 20.days)
    end

    it "should return nothing if user has no tasks" do
      user1 = User.make!
      user1.schedule.should eq(nil)
    end

    it "should return one scheduled shift if user has one task with the same duration as the minimum schedule shift duration" do
      time_travel_to(@now)
      # scheduled_shift = ScheduledShift.new
      # puts @user2.scheduled_shifts.all.inspect
      @user2.schedule
      @user2.scheduled_shifts.size.should eq(5)
    end

    describe "#work_time_left" do
      after(:each) { back_to_the_present }

      before do
        day_of_week = Time.now.strftime("%A").downcase #The user works on the day the test is run
        @now = Time.parse("10-04-2009 10:00 UTC")
        @user2 = User.make!(:min_scheduled_shift_length => 2, :"#{day_of_week}" => true)
        @ws0 = WorkShift.make!(:start_time => Time.parse("10-04-2009 06:30 UTC"), :duration => 2, :user_id => @user2.id)
        @ws1 = WorkShift.make!(:start_time => Time.parse("10-04-2009 09:30 UTC"), :duration => 2, :user_id => @user2.id)
        @ws2 = WorkShift.make!(:start_time => Time.parse("10-04-2009 13:00 UTC"), :duration => 2, :user_id => @user2.id)
        @ws3 = WorkShift.make!(:start_time => Time.parse("10-04-2009 16:10 UTC"), :duration => 3, :user_id => @user2.id)
      end

      it "should return the work time in minutes if there is work time left today" do
        @user2.work_time_left(@now).should eq(330)
      end

      it "shoud return zero if there isn't work time left today" do
        time_travel_to(@now + 10.hours)
        now = Time.now
        @user2.work_time_left(now).should eq(0)
      end
    end

  end
end









