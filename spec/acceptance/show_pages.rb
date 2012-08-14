# encoding: utf-8
feature "Show pages", %q{
  In order to view the different parts of the site
  As a user
  I want to be able to click around
} do

  background do
    @user1 = User.make!( :email => "pp@gmail.com", :password => "abcd1234" )

    # break out into helper method
    visit('/log_in')
    fill_in('email', :with => "pp@gmail.com")
    fill_in('password', :with => "abcd1234")
    click_button('login')
  end

  scenario "Clients" do
    visit('/clients')

    page.should have_content('Uppdragsgivare')
  end
end
