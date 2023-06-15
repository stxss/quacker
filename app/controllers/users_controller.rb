class UsersController < ApplicationController
  def show
    fetch_user
  end

  def index_liked_tweets
    fetch_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    respond_to do |format|
      if @user.update(user_params)
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace("user-profile", partial: "users/profile_banner", locals: {user: current_user}),
            turbo_stream.update("modal", "")
          ]
        }
        format.html { redirect_to username_url(current_user.username) }
      else
        flash.now[:alert] = "Oops, something went wrong, check your fields again"
        render :edit, status: :unprocessable_entity
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:display_name, :biography, :location, :website, :birth_date)
  end

  def fetch_user
    @user = User.find_by(username: params[:username])
  end
end
