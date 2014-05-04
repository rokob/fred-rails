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

  describe "as logged in user" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) { sign_in user, no_capybara: true }
    describe "signup page" do
      before { get signup_path }
      specify { expect(response).to redirect_to(root_url) }
    end

    describe "signin page" do
      before { get signin_path }
      specify { expect(response).to redirect_to(root_url) }
    end
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }

    describe "as a logged out user" do
      before(:each) { visit user_path(user) }

      it { should have_content('Sign in') }
      it { should have_title('Sign in') }
      it { should_not have_content(user.name) }
    end

    describe "as a logged in user" do
      before(:each) do
        sign_in user
        visit user_path(user)
      end

      it { should have_content(user.name) }
      it { should have_title(user.name) }
    end
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

    describe "forbidden attributes" do
      let(:params) do
        { user: { admin: true, password: user.password,
          password_confirmation: user.password } }
        end
        before do
          sign_in user, no_capybara: true
          patch user_path(user), params
        end
        specify { expect(user.reload).not_to be_admin }
      end
    end

    describe "index" do
      let(:user) { FactoryGirl.create(:user) }

      describe "as a non-admin user" do
        before(:each) do
          sign_in user
          visit users_path
        end

        it { should have_title('All users') }
        it { should have_content('All users') }

        it { should_not have_link('delete') }

        describe "pagination" do

          before(:all) { 30.times { FactoryGirl.create(:user) } }
          after(:all) { User.delete_all }

          it { should have_selector('div.pagination') }

          it "should list each user" do
            User.paginate(page: 1).each do |user|
              expect(page).to have_selector('li', text: user.name)
            end
          end
        end
      end

      describe "delete links" do
        describe "as admin user" do
          before(:all) { 2.times { FactoryGirl.create(:user) } }
          after(:all) { User.delete_all }

          let(:admin) { FactoryGirl.create(:admin) }
          before(:each) do
            sign_in admin
            visit users_path
          end

          it { should have_link('delete', href: user_path(User.first)) }

          it "should be able to delete another user" do
            expect do
              click_link('delete', match: :first)
            end.to change(User, :count).by(-1)
          end
          it { should_not have_link('delete', href: user_path(admin)) }
        end
      end
    end

  end
