class Promptcraft::Command::RechatConversationCommand
  include Promptcraft::Helpers

  def initialize(system_prompt:, conversation:, llm:)
    @system_prompt = system_prompt
    @conversation = conversation
    @llm = llm
  end

  attr_accessor :system_prompt, :conversation, :llm
  attr_reader :updated_conversation

  # At each point in @conversation messages where the assistant has replied, or not yet replied,
  # then ask the LLM to re-chat the preceding messages and generate a new response.
  def execute
    @updated_conversation = Promptcraft::Conversation.new(system_prompt:, llm:)

    conversation.messages.each do |message|
      message = deep_symbolize_keys(message)
      role = message[:role]
      if role == "assistant"
        messages = @updated_conversation.to_messages
        response_message = Promptcraft::Command::LlmChatCommand.new(messages: messages, llm: @llm).execute
        @updated_conversation.messages << response_message
      else
        @updated_conversation.messages << message
      end
    end

    # if last message is from user, then ask the LLM to generate a response
    unless @updated_conversation.messages.last&.dig(:role) == "assistant"
      messages = @updated_conversation.to_messages
      response_message = Promptcraft::Command::LlmChatCommand.new(messages: messages, llm: @llm).execute
      @updated_conversation.messages << response_message
    end
  end
end
