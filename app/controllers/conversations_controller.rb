class ConversationsController < ApplicationController
  def index
    @conversations = current_user.conversations
  end

  def new
  end

  def edit
  end

  def create
    @conversation = ConversationCreator.call(conversation_params, current_user)

    redirect_to conversations_path
  end

  def destroy
  end

  private

  def conversation_params
    params.require(:conversation).permit(:name, member_ids: [])
  end
end
