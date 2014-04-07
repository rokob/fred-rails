require 'spec_helper'

describe "User Pages" do
  subject { page }

  describe "signup page" do
    before(:each) { visit signup_path }

    it { should have_content('Sign up') }
    it { should have_title(full_title("Sign up")) }

    let(:submit) { "Create my account" }

    describe "with valid input" do
      before do
        fill_in "Name", with: "Handsome Dan"
        fill_in "Email", with: "dan@example.com"
        fill_in "Password", with: "foobar123"
        fill_in "Confirmation", with: "foobar123"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before(:each) { click_button submit }
        let(:user) { User.find_by(email: 'dan@example.com') }

        it { should have_link('Sign out') }
        it { should have_content(user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
      end
    end

    describe "with invalid input" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before(:each) { click_button submit }

        it { should have_title('Sign up') }
        it { should have_content('error') }
      end
    end
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_title('Edit user') }
      it { should have_content('Update your profile') }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before(:each) { click_button 'Save changes' }

      it { should have_content('error') }
    end

    describe "with valid information" do
      let(:new_name) { "Bill NewNamerson" }
      let(:new_email) { "bill@name.com" }
      before(:each) do
        fill_in "Name", with: new_name
        fill_in "Email", with: new_email
        fill_in "Password", with: user.password
        fill_in "Confirmation", with: user.password
        click_button 'Save changes'
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { expect(user.reload.name).to  eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end
  end

end
