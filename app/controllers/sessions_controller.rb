class SessionsController < ApplicationController

  def new
  end

  def create
    user = find_user(session_params)
    if user && authenticate(user, session_params)
      sign_in user
      redirect_back_or user
    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

  private
    def session_params
      params.require(:session).permit(:email, :password)
    end

    def find_user(hash)
      User.find_by(email: hash[:email].downcase)
    end

    def authenticate(user, hash)
      user.authenticate(hash[:password])
    end
end
