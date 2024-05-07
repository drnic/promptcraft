require "langchain"

class Promptcraft::Command::LlmChatCommand
  attr_reader :messages, :llm

  def initialize(messages:, llm:)
    @messages = messages
    @llm = llm
  end

  def execute
    response = @llm.chat(messages:)
    response_message = response.chat_completions&.dig(0, "message")
    response_message = response_message.transform_keys(&:to_sym) if response_message.is_a?(Hash)
    response_message
  rescue => e
    puts e.message
    raise
  end
end
