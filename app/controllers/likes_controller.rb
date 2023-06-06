class LikesController < ApplicationController
  def create
    @like = current_user.like_tweet(like_params)

    if @like.save
      redirect_to request.referrer
    else
      flash.now[:alert] = "Oops, something went wrong, check your fields again"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @like = Like.find(params[:id])

    redirect_to request.referrer if @like.destroy
  end

  private

  def like_params
    params.require(:like).permit(:tweet_id)
  end
end
