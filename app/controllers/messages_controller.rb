class MessagesController < ApplicationController
  class BlankMessage < StandardError; end

  skip_before_action :set_query, only: [:show]

  def new
    @message = Message.new
  end

  def messages
    @messages = conversation.messages
  end

  def search
    @messages_search = Message.search(params[:query]).includes(:sender).order(created_at: :desc)
    @query = params[:query]
    render partial: "search/message_form", locals: {messages_search: @messages_search, query: @query}
  end

  def create
    @message = if params[:post_share]
      MessageCreator.call(params, current_user)
    else
      raise BlankMessage if message_params[:body].rstrip == ""
      current_user.sent_messages.build(body: message_params[:body].rstrip, sender_id: current_user.id, conversation_id: message_params[:conversation_id].to_i)
    end

    if @message.save
      @message.conversation.touch
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
          render turbo_stream: turbo_stream.update("message-form", @message.errors.full_messages.first)
        }
        format.html { redirect_to conversation_path(id: @message.conversation.id) }
      end
    end
  rescue BlankMessage
    respond_to do |format|
      format.turbo_stream {
        flash.now[:alert] = "Nah fam, you can't send an empty message lol"
        render turbo_stream: [
          turbo_stream.replace("message-form button[type=submit]", helpers.send_message_icon),
          helpers.render_flash_message
        ]
      }
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
