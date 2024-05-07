require "langchain"

class Promptcraft::Command::LlmChatCommand
  attr_reader :messages, :llm

  def initialize(messages:, llm:)
    @messages = messages
    @llm = llm
  end

  def execute
    response = @llm.chat(messages:)
    response.completions&.dig(0, "message")
  rescue => e
    puts e.message
    raise
  end
end
