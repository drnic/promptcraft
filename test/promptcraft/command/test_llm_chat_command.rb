require "test_helper"
require "langchain"
require "openai"

module Promptcraft::Command
  class TestLlmChatCommand < Minitest::Test
    def test_basic_maths_groq
      llm = Promptcraft::Llm.new(provider: "groq")
      VCR.use_cassette("command/llm_chat_command/test_groq") do
        messages = [{role: "user", content: "What is 2 + 2?"}]
        command = LlmChatCommand.new(messages:, llm:)
        message = command.execute
        assert_equal({role: "assistant", content: "The answer to 2 + 2 is 4."}, message)
      end
    end

    def test_openrouter
      llm = Promptcraft::Llm.new(provider: "openrouter")
      VCR.use_cassette("command/llm_chat_command/test_openrouter") do
        messages = [{role: "user", content: "What is 2 + 2?"}]
        command = LlmChatCommand.new(messages:, llm:)
        message = command.execute
        assert_equal({role: "assistant", content: "The answer to 2 + 2 is 4."}, message)
      end
    end

    def test_ollama
      llm = Promptcraft::Llm.new(provider: "ollama")
      VCR.use_cassette("command/llm_chat_command/test_ollama") do
        messages = [{role: "user", content: "What is 2 + 2?"}]
        command = LlmChatCommand.new(messages:, llm:)
        message = command.execute
        assert_equal({role: "assistant", content: "The answer to 2 + 2 is... (drumroll please)... 4!"}, message)
      end
    end
  end
end
