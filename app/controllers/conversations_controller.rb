class ConversationsController < ApplicationController
  def index
    @conversations = current_user.conversations
  end

  def show
    @conversations = current_user.conversations
    @conversation = Conversation.find(params[:id])
    respond_to do |format|
      format.turbo_stream
      format.html {}
    end
  end

  def new
  end

  def edit
  end

  def create
    @members = conversation_params[:member_ids].reject(&:blank?)
    existing_conversation = Conversation.find_by_members(@members)&.first

    if existing_conversation
      redirect_to conversation_path(id: existing_conversation.id)
    else
      @conversation = ConversationCreator.call(conversation_params, current_user)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to conversation_path(id: @conversation.id) }
      end
    end
  end

  def destroy
  end

  private

  def conversation_params
    params.require(:conversation).permit(:name, member_ids: [])
  end
end
