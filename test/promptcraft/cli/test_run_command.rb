require "test_helper"

module Promptcraft::Cli
  class TestRunCommand < Minitest::Test
    def setup
      @cli = RunCommand.new
    end

    def test_help
      @cli.parse(%w[--help])
      assert_output(/Usage:/) { @cli.run }
    end

    def test_required_options
      @cli.parse(%w[])
      assert_output(/Option '--conversation' should appear at least 1 time/i) { @cli.run }
    end

    def test_conversation_stream
      VCR.use_cassette("run_command/simple_maths") do
        @cli.parse(%w[--conversation test/fixtures/prompts/simple_maths_stream.yml])
        expected_output = <<~OUTPUT
          ---
          system_prompt: I like to solve maths problems.
          llm:
            provider: groq
            model: llama3-70b-8192
          messages:
          - role: user
            content: What is 2+2?
          - role: assistant
            content: That's an easy one! The answer is... 4!
          ---
          system_prompt: I like to solve maths problems.
          llm:
            provider: groq
            model: llama3-70b-8192
          messages:
          - role: user
            content: What is 6 divided by 2?
          - role: assistant
            content: 6 divided by 2 is 3.
        OUTPUT
        assert_output(expected_output) { @cli.run }
      end
    end

    def test_multiple_conversations
      VCR.use_cassette("run_command/simple_maths") do
        @cli.parse(%w[--conversation test/fixtures/prompts/simple_maths_1.yml -c test/fixtures/prompts/simple_maths_2.yml])
        expected_output = <<~OUTPUT
          ---
          system_prompt: I like to solve maths problems.
          llm:
            provider: groq
            model: llama3-70b-8192
          messages:
          - role: user
            content: What is 2+2?
          - role: assistant
            content: That's an easy one! The answer is... 4!
          ---
          system_prompt: I like to solve maths problems.
          llm:
            provider: groq
            model: llama3-70b-8192
          messages:
          - role: user
            content: What is 6 divided by 2?
          - role: assistant
            content: 6 divided by 2 is 3.
        OUTPUT
        assert_output(expected_output) { @cli.run }
      end
    end
  end
end
