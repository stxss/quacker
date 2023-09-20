class MessagesController < ApplicationController
  def new
  end

  def index
    @messages = current_user.conversations
  end

  def create
    @message = Message.build(message_params)

    if @message.save
      respond_to do |format|
        format.turbo_stream
      end
    end
  end

  def show
  end

  private

  def message_params
    params.require(:message).permit(:body, :sender_id, :conversation_id)
  end
end
