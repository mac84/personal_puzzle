# encoding: utf-8
feature "Timer" do
  background do
    @user1 = User.make!( :email => "pp@gmail.com", :password => "abcd1234" )
    Task.make!(:user => @user1, :client => Client.make!)

    visit('/log_in')
    fill_in('E-postadress', :with => "pp@gmail.com")
    fill_in('Lösenord', :with => "abcd1234")
    click_button('login')

    visit('/tasks')
  end

  scenario "starting a timer", :javascript => true do
    click_button('.icon-play')
    time_travel_to(20.minutes.from_now)

    page.should have_content('00:20:00')

  end

end