class Promptcraft::Command::RechatConversationCommand
  def initialize(system_prompt:, conversation:, llm:)
    @system_prompt = system_prompt
    @conversation = conversation
    @llm = llm
  end

  attr_accessor :conversation, :llm
  attr_reader :updated_conversation

  # At each point in @conversation messages where the assistant has replied, or not yet replied,
  # then ask the LLM to re-chat the preceding messages and generate a new response.
  def execute
    @updated_conversation = Promptcraft::Conversation.new(system_prompt: @system_prompt)

    conversation.messages.each do |message|
      role = message[:role] || message["role"]
      if role == "assistant"
        messages = @updated_conversation.to_messages
        response_message = Promptcraft::Command::LlmChatCommand.new(messages: messages, llm: @llm).execute
        @updated_conversation.messages << response_message
      else
        @updated_conversation.messages << message
      end
    end

    # Iterate over the messages in the conversation, finding role=asssistant messages,
    # and re-chatting the preceding messages to generate a new response.
  end
end
