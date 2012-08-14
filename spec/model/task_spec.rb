describe "Task" do
  let(:task)   { Task.make! }
  let(:user)   { User.make! }
  let(:client) { Client.make! }

  describe "validations" do
    it "can be valid" do
      Task.make.should be_valid
    end

    it "must have a name" do
      task.should_not allow(nil, "", " ").as(:name)
    end
  end

  describe "#client_name" do
    it "should delegate to client.name if client exists" do
      client = Client.make(:name => "Elabs")
      task = Task.make(:client => client)
      task.client_name.should eq("Elabs")
    end
    it "should return nil if the client doesn't exist" do
      client = nil
      task = Task.make(:client => client)
      task.client_name.should eq(nil)
    end
  end

  context "the timer", :pending => true do
    before do
      @task1 = Task.make!(:client => client, :user => user)
      @now = Time.now
      @task1.start_timer
      time_travel_to(20.minutes.from_now)
      @task1.stop_timer
    end

    it "should add a completed shift for the task" do
      @task1.completed_shifts.should_not be_empty
    end

    it "should add the duration between start and stop as the duration for the completed shift" do
      shift1 = @task1.completed_shifts.first
      shift1.start_date.should eq(now)
      shift1.duration.should eq(20)
    end
  end
end
