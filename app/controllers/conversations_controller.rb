class ConversationsController < ApplicationController
  skip_before_action :set_query, only: [:index, :show]
  before_action :verify_membership, only: [:show]

  def index
    @conversations = current_user.conversations
  end

  def show
    @user = current_user
    @conversations = current_user.conversations
    @conversation = Conversation.find(params[:id])
    @other_user = @conversation.members.excluding(current_user).first if @conversation.members.size == 2
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

  def verify_membership
    @conversation = Conversation.find(params[:id])
    raise ActionController::RoutingError.new("Not Found") if !@conversation.members.include?(current_user)
  end
end
