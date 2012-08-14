# encoding: utf-8
feature "Logging in" do
  background do
    @user1 = User.make!( :email => "pp@gmail.com", :password => "abcd1234" )
    visit('/')
  end

  scenario "with a valid username and password" do
    fill_in('E-postadress', :with => "pp@gmail.com")
    fill_in('Lösenord', :with => "abcd1234")
    click_button('Logga in')

    page.should have_content('Välkommen pp@gmail.com')
  end

  scenario "with wrong username" do
    fill_in('E-postadress', :with => "ap@gmail.com")
    fill_in('Lösenord', :with => "abcd1234")
    click_button('Logga in')

    page.should have_content('Felaktigt användarnamn eller lösenord')
  end

  scenario "with wrong password" do
    fill_in('E-postadress', :with => "pp@gmail.com")
    fill_in('Lösenord', :with => "wrong")
    click_button('Logga in')

    page.should have_content('Felaktigt användarnamn eller lösenord')
  end

  scenario "then logging out" do
    fill_in('E-postadress', :with => "pp@gmail.com")
    fill_in('Lösenord', :with => "abcd1234")
    click_button('Logga in')
    page.should have_content('Välkommen pp@gmail.com')

    click_button('Logga ut')
    page.should have_content('Utloggad!')

  end

end
