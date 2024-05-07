class Promptcraft::Command::RechatConversationCommand
  def initialize(prompt:, conversation:, llm:)
    @prompt = prompt
    @conversation = conversation
    @llm = llm
  end

  attr_accessor :conversation, :llm

  # At each point in @conversation messages where the assistant has replied, or not yet replied,
  # then ask the LLM to re-chat the preceding messages and generate a new response.
  def execute
    @updated_conversation = @conversation.dup
    @updated_conversation.system_prompt = @prompt

    # Iterate over the messages in the conversation, finding role=asssistant messages,
    # and re-chatting the preceding messages to generate a new response.

    messages = @updated_conversation.to_messages
    response = Promptcraft::Command::LlmChatCommand.new(messages: messages, llm: @llm).execute
    @updated_conversation.add_message(role: "user", content: response)
  end
end
