class MessageCreator < ApplicationService
  def initialize(params, sender)
    @sender = sender
    @body = params[:message][:body].rstrip
    @conversations = params[:message][:conversation_id].reject(&:blank?) # in messages/share_post, the option 'include_hidden: false' should already cover rejecting blanks, but just in case ill add it here too
    @post = params[:post_share][:id]
    @username = params[:post_share][:username]
    @url = Rails.application.routes.url_helpers.single_post_url(username: @username, id: @post)
    @new_body = @url << " " << @body
  end

  def call
    @conversations.each do |conversation|
      @message = @sender.sent_messages.build(body: @new_body, sender_id: @sender.id, conversation_id: conversation.to_i)
      @message.save
    end
    @message
  end
end
