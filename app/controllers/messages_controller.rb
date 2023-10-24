class MessagesController < ApplicationController
  def new
    @message = Message.new
  end

  def index
    user_conversations = current_user.conversations.ordered

    @conversations = user_conversations.reject do |conversation|
      no_messages = conversation.messages.empty? && conversation.creator != current_user
      two_members = conversation.members.size == 2
      other_user = conversation.members.excluding(current_user).first

      no_messages || (two_members && current_user.account.has_blocked?(other_user))
    end
  end

  def messages
    @messages = conversation.messages
  end

  def create
    @message = current_user.sent_messages.build(body: message_params[:body], sender_id: current_user.id, conversation_id: message_params[:conversation_id].to_i)
    @receiver = @message.conversation.members.excluding(current_user).first

    if @message.save
      @message.conversation.members.each do |member|
        next if member == @message.sender

        @message.broadcast_append_to ["#{member&.to_gid_param}:#{@message.conversation&.to_gid_param}"],
          target: "message-list",
          partial: "messages/message",
          locals: {message: @message}
      end
    elsif @message.errors.any?
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream:
            turbo_stream.update("message-form", @message.errors.full_messages.first)
        }
        format.html { redirect_to conversation_path(id: @message.conversation.id) }
      end
    end
  end

  def show
  end

  private

  def message_params
    params.require(:message).permit(:body, :conversation_id)
  end
end
