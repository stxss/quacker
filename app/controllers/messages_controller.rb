class MessagesController < ApplicationController
  skip_before_action :set_query, only: [:index, :show]

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

  def search
    @messages_search = Message.search(params[:query]).includes(:sender).order(created_at: :desc)
    @query = params[:query]
    render partial: "search/message_form"
  end

  def create
    @message = if params[:post_share]
      MessageCreator.call(params, current_user)
    else
      current_user.sent_messages.build(body: message_params[:body].rstrip, sender_id: current_user.id, conversation_id: message_params[:conversation_id].to_i)
    end

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

  def share_post
  end

  def show
  end

  private

  def message_params
    params.require(:message).permit(:body, :conversation_id)
  end
end
