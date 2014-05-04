require 'spec_helper'

describe "Friendship Pages" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let(:friend) { FactoryGirl.create(:user) }
  let(:requested_friend) { FactoryGirl.create(:user) }
  let(:pending_friend) { FactoryGirl.create(:user) }
  let(:requestable_user) { FactoryGirl.create(:user) }

  before(:each) do
    Friendship.request(user, friend)
    Friendship.accept(friend, user)
    Friendship.request(requested_friend, user)
    Friendship.request(user, pending_friend)
    requestable_user.save

    sign_in user
  end

  describe "friends page" do
    before { visit friendships_path }

    it { should have_title('Friends') }
    it { should have_content(friend.name) }
    it { should have_content('Unfriend') }

    describe "unfriending" do
      before do
        click_button 'Unfriend'
        visit friendships_path
      end

      it { should have_title('Friends') }
      it { should_not have_content(friend.name) }
    end
  end

  describe "requests page" do
    before { visit requested_friendships_path }

    it { should have_title('Friend Requests') }
    it { should have_content(requested_friend.name) }
    it { should have_content('Accept') }
    it { should have_content('Reject') }

    describe "accepting" do
      before { click_button 'Accept' }

      describe "requests after action" do
        before { visit requested_friendships_path }

        it { should have_title('Friend Requests') }
        it { should_not have_content(requested_friend.name) }
      end

      describe "friendships after action" do
        before { visit friendships_path }

        it { should have_content(requested_friend.name) }
      end
    end

    describe "rejecting" do
      before { click_button 'Reject' }

      describe "requests after action" do
        before { visit requested_friendships_path }

        it { should have_title('Friend Requests') }
        it { should_not have_content(requested_friend.name) }
      end

      describe "friendships after action" do
        before { visit friendships_path }

        it { should_not have_content(requested_friend.name) }
      end
    end
  end

  describe "pending page" do
    before { visit pending_friendships_path }

    it { should have_title('Friendships Pending') }
    it { should have_content(pending_friend.name) }
    it { should have_content('Cancel') }

    describe "canceling" do
      before { click_button 'Cancel' }

      describe "pending requests after action" do
        before { visit pending_friendships_path }

        it { should have_title('Friendships Pending') }
        it { should_not have_content(pending_friend.name) }
      end

      describe "friendships after action" do
        before { visit friendships_path }

        it { should_not have_content(pending_friend.name) }
      end
    end
  end

  describe "creating a new friend" do
    before { visit users_path }

    it { should have_content(requestable_user.name) }
    it { should have_content('Send friend request') }

    describe "sending a request" do
      before { click_button 'Send friend request' }

      describe "pending requests after request" do
        it { should have_content(requestable_user.name) }
      end

      describe "user list after request" do
        before { visit users_path }

        it { should_not have_content('Send friend request') }
      end
    end
  end
end