class MutedWordsController < ApplicationController
  def index
    @muted_words = current_user.account.muted_words
  end

  def create
    @muted_word = current_user.account.muted_words.build(muted_words_params)

    if @muted_word.save
      redirect_to muted_words_path
    end
  end

  private

  def muted_words_params
    params.require(:muted_word).permit(:body, :from_timeline, :from_notifications, :expiration)
  end
end
