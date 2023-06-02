class UsersController < ApplicationController
  def show
    @user = User.find_by(username: params[:username])
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
            turbo_stream.replace("user-profile", partial: "users/show_profile", locals: {user: current_user}),
            turbo_stream.update("modal", "")
          ]
        }
        # format.html { redirect_to username_url(current_user.username) }
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
end
