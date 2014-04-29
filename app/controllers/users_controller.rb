class UsersController < ApplicationController
  before_action :signed_in_user, only: [:index, :edit, :update, :destroy, :friends, :friend_requests]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  before_action :not_current_user, only: :destroy
  before_action :not_signed_in, only: [:new, :create]

  def index
    @users = User.all_with_friends_paginated(current_user, params)
  end

  def show
    @user = find_user
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    find_user.destroy
    flash[:success] = "User deleted."
    redirect_to users_url
  end

  def friends
    @user = find_user
    @users = @user.friends.paginate(page: params[:page])
  end

  def friend_requests
    @user = find_user
    @users = @user.friend_requests.paginate(page: params[:page])
  end

  private
    def user_params
      params.require(:user).permit(:name,
                                   :email,
                                   :password,
                                   :password_confirmation)
    end

    def find_user
      User.find(params[:id])
    end

    def not_signed_in
      redirect_to root_url if signed_in?
    end

    def correct_user
      @user = find_user
      redirect_to root_url unless current_user?(@user)
    end

    def admin_user
      redirect_to root_url unless current_user.admin?
    end

    def not_current_user
      redirect_to root_url if current_user?(find_user)
    end
end
