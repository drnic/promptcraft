require "langchain"

class Promptcraft::Command::LlmChatCommand
  attr_reader :messages, :llm

  def initialize(messages:, llm:)
    @messages = messages
    @llm = llm
  end

  def execute
    # cleanse messages of missing content, role, etc
    messages = @messages.reject { |m| m[:content].nil? || m[:content].empty? || m[:role].nil? || m[:role].empty? }
    response = @llm.chat(messages:)

    response_text = response.chat_completion
    {role: "assistant", content: response_text}
  rescue => e
    puts e.message
    raise
  end
end
