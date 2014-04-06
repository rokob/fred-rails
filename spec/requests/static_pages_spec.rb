require 'spec_helper'

describe "Static Pages" do

  let (:base_title) { "Fred" }

  subject { page }

  describe "Home page" do
    before(:each) { visit root_path }
    it { should have_content('Fred') }
    it { should have_title(full_title("")) }
    it { should_not have_title('| Home') }
  end

  describe "About page" do
    before(:each) { visit about_path }
    it { should have_content('About Us') }
    it { should have_title(full_title("About Us")) }
  end

  describe "Contact page" do
    before(:each) { visit contact_path }
    it { should have_content('Contact') }
    it { should have_title(full_title("Contact")) }
  end

  it "should have the right links on the layout" do
    visit root_path
    find('footer').click_link "About"
    expect(page).to have_title(full_title('About Us'))
    click_link "Contact"
    expect(page).to have_title(full_title('Contact'))
    # click_link "Home"
    # click_link "Sign up now!"
    # expect(page).to # fill in
    click_link "fred"
    expect(page).to have_title(full_title(''))
  end
end
