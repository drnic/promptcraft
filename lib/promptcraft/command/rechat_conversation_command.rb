class Promptcraft::Command::RechatConversationCommand
  def initialize(conversation:, llm:)
    @conversation = conversation
    @llm = llm
  end

  attr_accessor :conversation, :llm

  # At each point in @conversation messages where the assistant has replied, or not yet replied,
  # then ask the LLM to re-chat the preceding messages and generate a new response.
  def execute
    messages = @conversation.to_messages
    response = Promptcraft::Command::LlmChatCommand.new(messages: messages, llm: @llm).execute
    @conversation.add_message(role: "user", content: response)
  end
end
