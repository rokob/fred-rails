require 'spec_helper'

describe "User Pages" do
  subject { page }

  describe "signup page" do
    before(:each) { visit signup_path }

    it { should have_content('Sign up') }
    it { should have_title(full_title("Sign up")) }
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end
end
