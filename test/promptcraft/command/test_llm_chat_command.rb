require "test_helper"
require "langchain"
require "openai"

module Promptcraft::Command
  class TestLlmChatCommand < Minitest::Test
    def test_basic_maths_groq
      llm = Promptcraft::Llm.langchain(provider: "groq")
      VCR.use_cassette("groq/llama3-70b/llm_chat_command/test_basic_maths_groq") do
        messages = [{role: "user", content: "What is 2 + 2?"}]
        command = LlmChatCommand.new(messages:, llm:)
        message = command.execute
        assert_equal message["role"], "assistant"
        assert_equal message["content"], "The answer to 2 + 2 is 4."
      end
    end
  end
end
