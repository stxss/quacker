class ConversationCreator < ApplicationService
  def initialize(params, creator)
    @creator = creator
    @name = params[:name]
    @members = params[:member_ids].reject(&:blank?)
  end

  def call
    existing_conversation = Conversation.find_by_members(@members)

    if existing_conversation
      return existing_conversation
    else
      @conversation = @creator.created_conversations.build(name: @name)
      @conversation.members << @creator

      users_to_add = User.where(id: @members)
      @conversation.members << users_to_add

      @conversation.save
    end
  end
end
