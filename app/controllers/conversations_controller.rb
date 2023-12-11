class ConversationsController < ApplicationController
  skip_before_action :set_query, only: [:index, :show]
  before_action :verify_membership, only: [:show]

  def index
    user_conversations = current_user.conversations.ordered

    @conversations = user_conversations.reject do |conversation|
      no_messages = conversation.messages.empty? && conversation.creator != current_user
      two_members = conversation.members.size == 2
      other_user = conversation.members.excluding(current_user).first

      no_messages || (two_members && current_user.account.has_blocked?(other_user))
    end
    respond_to do |format|
      format.html { render template: "conversations/index", locals: {conversations: @conversations, messages_search: [], query: ""} }
    end
  end

  def show
    @conversations = current_user.conversations.ordered
    @conversation = Conversation.find(params[:id])
    @other_user = @conversation.members.excluding(current_user).first if @conversation.members.size == 2
    respond_to do |format|
      format.turbo_stream
      format.html { render template: "conversations/show", locals: {conversations: @conversations, conversation: @conversation, user_gid: current_user.to_gid_param, other_user: @other_user, messages_search: [], query: ""} }
    end
  end

  def new
  end

  def edit
  end

  def create
    conversation_params
    @members = (conversation_params[:member_ids].reject(&:blank?) << current_user.id).map(&:to_i)
    existing_conversation = current_user.conversations.any? { |c| c.member_ids == @members }

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
    raise ActionController::RoutingError.new("Not Found") unless @conversation.members.include?(current_user)
  end
end
