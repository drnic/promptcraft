require "test_helper"
require "langchain"
require "openai"

module Promptcraft::Command
  class TestLlmChatCommand < Minitest::Test
    def setup
      if ENV["GROQ_API_KEY"]
        @groq = @llm = Langchain::LLM::OpenAI.new(
          api_key: ENV["GROQ_API_KEY"],
          llm_options: {
            uri_base: "https://api.groq.com/openai/"
          },
          default_options: {
            chat_completion_model_name: "llama3-70b-8192"
          }
        )
      end

      raise "No LLM configured" unless @llm
    end

    def test_basic_maths_groq
      skip unless @groq
      VCR.use_cassette("groq/llama3-70b/llm_chat_command/test_basic_maths_groq") do
        messages = [{role: "user", content: "What is 2 + 2?"}]
        command = LlmChatCommand.new(messages:, llm: @groq)
        message = command.execute
        assert_equal message["role"], "assistant"
        assert_equal message["content"], "The answer to 2 + 2 is 4."
      end
    end
  end
end
