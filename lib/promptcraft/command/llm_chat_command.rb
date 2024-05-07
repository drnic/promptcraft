require "langchain"

class Promptcraft::Command::LlmChatCommand
  attr_reader :messages, :llm

  def initialize(messages:, llm:)
    @messages = messages
    @llm = llm
  end

  def execute
    response = @llm.chat(messages:)
    # response.chat_completions
    # pp response.chat_completion
    response.chat_completions&.dig(0, "message")
  rescue => e
    puts e.message
    raise
  end
end
