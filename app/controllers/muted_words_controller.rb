class MutedWordsController < ApplicationController
  def index
    @muted_words = current_user.account.muted_words
  end

  def create
    @muted_word = current_user.account.muted_words.build(muted_words_params)

    @muted_word.expiration = if muted_words_params[:expiration].in? %w[1 7 30]
      muted_words_params[:expiration].to_i.days.from_now
    end

    if @muted_word.save
      redirect_to muted_words_path
      MutedWordsCleanupJob.perform_at(@muted_word.expiration, @muted_word.id)
    end
  end

  def destroy
    @muted_word = current_user.account.muted_words.find(params[:id])
    @muted_word.destroy
    @muted_words = current_user.account.muted_words
  end

  private

  def muted_words_params
    params.require(:muted_word).permit(:body, :from_timeline, :from_notifications, :expiration)
  end
end
