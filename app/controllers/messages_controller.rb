class MessagesController < ApplicationController
  def new
    @message = Message.new
  end

  def index
    @conversations = current_user.conversations
  end

  def messages
    @messages = conversation.messages
  end

  def create
    @message = current_user.sent_messages.build(body: message_params[:body], sender_id: current_user.id, conversation_id: message_params[:conversation_id].to_i)
    @message.save

    @message.broadcast_append_to "messages",
      target: "message-list",
      partial: "messages/message",
      locals: {message: @message}

    respond_to do |format|
      format.turbo_stream
      # format.html { redirect_to request.referrer }
      # current_user.notify(@tweet.author.id, :like, tweet_id: @tweet.id)
    end
  end

  def show
  end

  private

  def message_params
    params.require(:message).permit(:body, :conversation_id)
  end
end
