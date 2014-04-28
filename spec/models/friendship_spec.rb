require 'spec_helper'

describe Friendship do
  let(:user) { FactoryGirl.create(:user) }
  let(:friend) { FactoryGirl.create(:user) }

  describe "creation" do
    describe "with yourself" do
      it { expect { Friendship.request(user, user) }.not_to change{ user.friends.size } }
    end

    describe "with a friend" do
      before do
        Friendship.create(user: user, friend: friend, status: Friendship::ACCEPTED)
        Friendship.create(user: friend, friend: user, status: Friendship::ACCEPTED)
      end

      it "should not change the user's friends" do
        expect { Friendship.request(user, friend).not_to change{ user.friends.size} }
      end

      it "should not change the friend's friends" do
        expect { Friendship.request(user, friend).not_to change{ friends.friends.size} }
      end

      it "should not change the friend's requests" do
        expect { Friendship.request(user, friend).not_to change{ friend.friend_requests.size} }
      end

      it "should not change the user's pending requests" do
        expect { Friendship.request(user, friend).not_to change{ user.pending_requests.size} }
      end
    end

    describe "with a non-friend" do
      describe "with an already requested user" do
        before do
          Friendship.create(user: user, friend: friend, status: Friendship::PENDING)
          Friendship.create(user: friend, friend: user, status: Friendship::REQUESTED)
        end
        it { expect { Friendship.request(user, friend) }.not_to change{ user.pending_requests.size } }
      end

      describe "multiple requests" do
        it "should only add one pending request in the same direction" do
          expect {
            Friendship.request(user, friend)
            Friendship.request(user, friend)
          }.to change{ user.pending_requests.size }.by(1)
        end

        it "should only add one pending request in the other direction" do
          expect {
            Friendship.request(user, friend)
            Friendship.request(friend, user)
          }.to change{ user.pending_requests.size }.by(1)
        end
      end

      describe "with an unrequested user" do
        it "should create a request for the friend" do
          expect { Friendship.request(user, friend) }.to change{ friend.friend_requests.size }.by(1)
        end

        it "should create a pending request for the user" do
          expect { Friendship.request(user, friend) }.to change{ user.pending_requests.size }.by(1)
        end

        describe "mutation" do
          before(:each) do
            Friendship.request(user, friend)
          end

          describe "acceptance" do
            it "should add a friend to the user" do
              expect { Friendship.accept(friend, user) }.to change{ user.friends.size }.by(1)
            end

            it "should add a friend to the friend" do
              expect { Friendship.accept(friend, user) }.to change{ friend.friends.size }.by(1)
            end

            it "should have the user a friend of the friend" do
              Friendship.accept(friend, user)
              user.friends.should include(friend)
            end

            it "should have the friend as a friend of the user" do
              Friendship.accept(friend, user)
              friend.friends.should include(user)
            end

            it "should work in both directions" do
              Friendship.accept(friend, user)
              user.friends.should include(friend)
              friend.friends.should include(user)
            end
          end

          describe "rejection" do
            it "should remove the pending request from the user" do
              expect { Friendship.reject(friend, user) }.to change{ user.pending_requests.size }.by(-1)
            end

            it "should remove the request from the friend" do
              expect { Friendship.reject(friend, user) }.to change{ friend.friend_requests.size }.by(-1)
            end

            it "should make it so user is not a requester of the friend" do
              Friendship.reject(friend, user)
              friend.friend_requests.should_not include(user)
            end
          end

          describe "cancellation" do
            it "should remove the pending request from the user" do
              expect { Friendship.cancel(user, friend) }.to change{ user.pending_requests.size }.by(-1)
            end

            it "should remove the request from the friend" do
              expect { Friendship.cancel(user, friend) }.to change{ friend.friend_requests.size }.by(-1)
            end

            it "should make it so user is not a requester of the friend" do
              Friendship.cancel(user, friend)
              friend.friend_requests.should_not include(user)
            end
          end
        end
      end
    end
  end

  let(:friendship) { user.friendships.build(friend_id: friend.id) }

  subject { friendship }

  it { should be_valid }

  describe "friend methods" do
    it { should respond_to(:user) }
    it { should respond_to(:friend) }

    its(:user) { should eq user }
    its(:friend) { should eq friend }
  end

  describe "when user id is not present" do
    before { friendship.user_id = nil }
    it { should_not be_valid }
  end

  describe "when friend id is not present" do
    before { friendship.friend_id = nil }
    it { should_not be_valid }
  end
end
