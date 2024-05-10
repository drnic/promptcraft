require "test_helper"

module Promptcraft
  class TestConversation < Minitest::Test
    def setup
      @convo = Conversation.new(system_prompt: "I solve math problems")
      @convo.add_message(role: "user", content: "What is 2 + 2?")
      @convo.add_message(role: "assistant", content: "2 + 2 is 4.")
    end

    def test_load_from_file_and_save_to_file_without_llm
      filename = "temp_test.yaml"
      @convo.save_to_file(filename)

      new_convos = Conversation.load_from_file(filename)

      assert_equal 1, new_convos.size
      new_convo = new_convos.first
      assert_equal @convo.system_prompt, new_convo.system_prompt
      assert_equal @convo.messages, new_convo.messages

      File.delete(filename) if File.exist?(filename)
    end

    def test_load_from_file_and_save_to_file_with_llm
      filename = "temp_test.yaml"
      @convo.llm = Llm.new(provider: "groq", model: "llama3-70b-8192")
      @convo.save_to_file(filename)

      new_convos = Conversation.load_from_file(filename)

      assert_equal 1, new_convos.size
      new_convo = new_convos.first
      assert_equal @convo.system_prompt, new_convo.system_prompt
      assert_equal @convo.messages, new_convo.messages
      assert new_convo.llm
      assert_equal @convo.llm.to_h, new_convo.llm.to_h

      File.delete(filename) if File.exist?(filename)
    end

    def test_load_from_io
      stdin = StringIO.new(<<~YAML)
        ---
        messages:
        - role: user
          content: 1 + 2?
        ---
        messages:
        - role: user
          content: Which animal is first in alphabet? Bear or Llama?
      YAML
      convos = Conversation.load_from_io(stdin)
      assert_equal 2, convos.size
      assert_equal({role: "user", content: "1 + 2?"}, convos.first.messages.first)
      assert_equal({role: "user", content: "Which animal is first in alphabet? Bear or Llama?"}, convos.last.messages.first)
    ensure
      stdin.close
    end

    def test_load_unstructured_user_messages
      stdin = StringIO.new(<<~YAML)
        ---
        1 + 2?
        ---
        Which animal is first in alphabet? Bear or Llama?
      YAML
      convos = Conversation.load_from_io(stdin)
      assert_equal 2, convos.size
      assert_equal({role: "user", content: "1 + 2?"}, convos.first.messages.first)
      assert_equal({role: "user", content: "Which animal is first in alphabet? Bear or Llama?"}, convos.last.messages.first)
    ensure
      stdin.close
    end

    def test_build_from
      convo = Conversation.build_from({
        "system_prompt" => "I solve math problems",
        "messages" => [
          {"role" => "user", "content" => "What is 2 + 2?"}
        ]
      })
      assert_equal "I solve math problems", convo.system_prompt
      assert_equal 1, convo.messages.size
      assert_equal "user", convo.messages.first[:role]
      assert_equal "What is 2 + 2?", convo.messages.first[:content]

      convo = Conversation.build_from("What's 1+2?")
      assert_nil convo.system_prompt
      assert_nil convo.llm
      assert_equal 1, convo.messages.size
      assert_equal "user", convo.messages.first[:role]
      assert_equal "What's 1+2?", convo.messages.first[:content]
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

  def test_add_message_and_to_yaml
    expected_yaml = <<~YAML
      ---
      system_prompt: I solve math problems
      messages:
      - role: user
        content: What is 2 + 2?
      - role: assistant
        content: 2 + 2 is 4.
    YAML
    assert_equal expected_yaml.strip, @convo.to_yaml.strip
  end
end
