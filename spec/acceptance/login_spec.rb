# encoding: utf-8
require 'acceptance/acceptance_helper'

feature "Login", %q{
  In order to make Personal Puzzle personal
  As a user
  I want to be able to login
} do

  background do
    @user1 = User.make!( :email => "pp@gmail.com", :password => "abcd1234" )
  end

  scenario "Logging in" do
    visit('/log_in')
    fill_in('email', :with => "pp@gmail.com")
    fill_in('password', :with => "abcd1234")
    click_button('login')

    page.should have_content('Välkommen pp@gmail.com')
  end
end