require "test_helper"

module Promptcraft::Command
  class TestRechatConversationCommand < Minitest::Test
    def test_one_message
      llm = Promptcraft::Llm.langchain(provider: "openai")
      VCR.use_cassette("openai/gpt3.5/rechat_conversation_command/test_one_message") do
        convo = Promptcraft::Conversation.new("I solve math problems")
        convo.add_message(role: "user", content: "What is 2 + 2?")

        command = RechatConversationCommand.new(conversation: convo, llm:)
        command.execute
      end
    end
  end
end
