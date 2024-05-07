require "test_helper"

module Promptcraft
  class TestConversation < Minitest::Test
    def setup
      @convo = Conversation.new("I solve math problems")
      @convo.add_message("user", "What is 2 + 2?")
      @convo.add_message("assistant", "2 + 2 is 4.")
    end

    def test_add_message_and_to_yaml
      expected_yaml = <<~YAML
        ---
        system_prompt: I solve math problems
        messages:
        - :role: user
          :content: What is 2 + 2?
        - :role: assistant
          :content: 2 + 2 is 4.
      YAML
      assert_equal expected_yaml.strip, @convo.to_yaml.strip
    end

    def test_load_from_file_and_save_to_file
      filename = "temp_test.yaml"
      @convo.save_to_file(filename)

      new_convo = Conversation.new
      new_convo.load_from_file(filename)

      assert_equal @convo.system_prompt, new_convo.system_prompt
      assert_equal @convo.messages, new_convo.messages

      File.delete(filename) if File.exist?(filename)
    end

    def test_to_messages
      expected_messages = [
        {role: "system", content: "I solve math problems"},
        {role: "user", content: "What is 2 + 2?"},
        {role: "assistant", content: "2 + 2 is 4."}
      ]

      assert_equal expected_messages, @convo.to_messages
    end

    def test_from_messages
      input_messages = [
        {role: "system", content: "I solve math problems"},
        {role: "user", content: "What is 2 + 2?"},
        {role: "assistant", content: "2 + 2 is 4."}
      ]

      convo_from_messages = Conversation.from_messages(input_messages)

      assert_equal "I solve math problems", convo_from_messages.system_prompt
      assert_equal input_messages[1..], convo_from_messages.messages
    end

    def test_from_messages_error
      wrong_messages = [
        {role: "user", content: "What is 2 + 2?"}
      ]

      assert_raises(ArgumentError) { Conversation.from_messages(wrong_messages) }
    end
  end
end
