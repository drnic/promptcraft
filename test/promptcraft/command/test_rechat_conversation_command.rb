require "test_helper"

module Promptcraft::Command
  class TestRechatConversationCommand < Minitest::Test
    def setup
      VCR.turn_off!
    end

    def teardown
      VCR.turn_on!
    end

    def test_one_message_missing_assistant
      system_prompt = "I solve math problems"
      convo = Promptcraft::Conversation.new(system_prompt:, messages: [{role: "user", content: "What is 2 + 2?"}])

      llm = Promptcraft::Llm.new(provider: "openai")

      stub_openai_chat_completion(
        messages: [{role: "system", content: system_prompt}, {role: "user", content: "What is 2 + 2?"}],
        response_content: "2 + 2 is 4."
      )

      command = RechatConversationCommand.new(system_prompt:, conversation: convo, llm:)
      command.execute

      # TODO: it should have added an assistant message
    end

    def test_one_message_replay_assistant
      system_prompt = "I solve math problems"
      convo = Promptcraft::Conversation.new(system_prompt:, messages: [
        {role: "user", content: "What is 2 + 2?"},
        {role: "assistant", content: "2 + 2 is 4."}
      ])

      llm = Promptcraft::Llm.new(provider: "openai")

      # The assistant message should be removed from the messages list
      # and replaced with a new message generated by the LLM
      #
      # Pass in a different system prompt to encourage a different response
      system_prompt = "When asked a question, I reply with a question."

      command = RechatConversationCommand.new(system_prompt:, conversation: convo, llm:)

      stub_openai_chat_completion(
        messages: [{role: "system", content: system_prompt}, {role: "user", content: "What is 2 + 2?"}],
        response_content: "If you have two apples and two oranges, how many do you have?"
      )

      command.execute

      updated_conversation = command.updated_conversation
      assert_equal "When asked a question, I reply with a question.", updated_conversation.system_prompt
      assert_equal 2, updated_conversation.messages.size
      assert_equal updated_conversation.messages, [
        {role: "user", content: "What is 2 + 2?"},
        {role: "assistant", content: "If you have two apples and two oranges, how many do you have?"}
      ]
    end

    # TODO: test_two_messages_missing_assistant
    def test_two_messages_missing_assistant
      # system_prompt = "I solve math problems"
    end

    def stub_openai_chat_completion(messages:, response_content:, model: "gpt-3.5-turbo")
      stub_request(:post, "https://api.openai.com/v1/chat/completions")
        .with(
          body: {messages: messages, model: model, n: 1, temperature: 0.0}.to_json
        )
        .to_return(
          status: 200,
          headers: {"Content-Type" => "application/json"},
          body: {"choices" => [{"message" => {"role" => "assistant", "content" => response_content}}]}.to_json
        )
    end
  end
end
