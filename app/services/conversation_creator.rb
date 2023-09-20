class ConversationCreator < ApplicationService
  def initialize(params, creator)
    @creator = creator
    @name = params[:name]
    @members = params[:member_ids].reject(&:blank?)
  end

  def call
    @conversation = @creator.created_conversations.create!(name: @name)
    @conversation.members << @creator

    users_to_add = User.where(id: @members)
    @conversation.members << users_to_add

    @conversation.save
  end
end
