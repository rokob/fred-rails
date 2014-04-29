class FriendshipsController < ApplicationController
  before_action :signed_in_user, only: [:index, :create, :destroy]

  def index
    @title = "Friends"
    @users = current_user.friends.paginate(page: params[:page])
    render_list [:unfriend]
  end

  def requested
    @title = "Friend Requests"
    @users = current_user.friend_requests.paginate(page: params[:page])
    render_list [:accept, :reject]
  end

  def pending
    @title = "Friendships Pending"
    @users = current_user.pending_requests.paginate(page: params[:page])
    render_list [:cancel]
  end

  def create
    @user = User.find(friendship_params[:friend_id])
    Friendship.request(current_user, @user)
    flash[:success] = "Request sent"
    redirect_to @user
  end

  def destroy
    friend = User.find(friendship_params[:friend_id])
    Friendship.unfriend(current_user, friend)
    redirect_to current_user
  end

  def accept
    friend = User.find(friendship_params[:friend_id])
    Friendship.accept(current_user, friend)
  end

  def reject
    friend = User.find(friendship_params[:friend_id])
    Friendship.reject(current_user, friend)
  end

  def cancel
    friend = User.find(friendship_params[:friend_id])
    Friendship.cancel(current_user, friend)
  end

  private
    def friendship_params
      params.require(:friendship).permit(:friend_id)
    end

    def render_list(allowed)
      actions = Hash.new
      allowed.each do |key|
        actions[key] = true
      end
      render 'friend_list', locals: {actions: actions}
    end

end