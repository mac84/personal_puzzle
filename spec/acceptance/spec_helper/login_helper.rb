module LoginHelper
  def login(email, password)
    visit('/log_in')
    fill_in('email', :with => "pp@gmail.com")
    fill_in('password', :with => "abcd1234")
    click_button('login')
  end
end