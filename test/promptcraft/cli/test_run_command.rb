require "test_helper"

module Promptcraft::Cli
  class TestRunCommand < Minitest::Test
    def setup
      @cli = RunCommand.new
    end

    # Single threaded run in tests to have deterministic STDOUT
    def cli_run
      @cli.run(threads: 1)
    end

    def test_help
      @cli.parse(%w[--help])
      assert_output("", /Usage:/) { cli_run }
    end

    def test_conversation_stream
      VCR.use_cassette("run_command/simple_maths_groq_llama3_70b") do
        @cli.parse(%w[--conversation test/fixtures/prompts/simple_maths_stream.yml])
        assert_output(expected_simple_maths_groq_llama3_7b) { cli_run }
      end
    end

    def test_multiple_conversations
      VCR.use_cassette("run_command/simple_maths_groq_llama3_70b") do
        @cli.parse(%w[--conversation test/fixtures/prompts/simple_maths_1.yml -c test/fixtures/prompts/simple_maths_2.yml])
        assert_output(expected_simple_maths_groq_llama3_7b) { cli_run }
      end
    end

    def test_conversations_via_stdin
      VCR.use_cassette("run_command/simple_maths_groq_llama3_70b") do
        stdin = File.open("test/fixtures/prompts/simple_maths_stream.yml", "r")
        @cli.parse([])
        assert_output(expected_simple_maths_groq_llama3_7b) { @cli.run(stdin:, threads: 1) }
      ensure
        stdin.close
      end
    end

    def test_no_conversation
      VCR.use_cassette("run_command/no_conversation_groq_llama3_70b") do
        @cli.parse([])
        expected_output = <<~OUTPUT
          ---
          system_prompt: You are helpful. If you're first, then ask a question. You like brevity.
          llm:
            provider: groq
            model: llama3-70b-8192
          messages:
          - role: assistant
            content: What do you need help with?
        OUTPUT
        assert_output(expected_output) { cli_run }
      end
    end

    def test_temperature_argument
      VCR.use_cassette("run_command/set_temperature_llama3_70b") do
        @cli.parse(%w[--temperature 0.5 --conversation test/fixtures/prompts/simple_maths_1.yml])
        expected_output = <<~OUTPUT
          ---
          system_prompt: I like to solve maths problems.
          llm:
            provider: groq
            model: llama3-70b-8192
            temperature: 0.5
          messages:
          - role: user
            content: What is 2+2?
          - role: assistant
            content: That's an easy one! The answer is... 4!
        OUTPUT
        assert_output(expected_output) { cli_run }
      end
    end

    def test_override_provider_and_model
      VCR.use_cassette("run_command/simple_maths_openai_gpt35") do
        @cli.parse(%w[--conversation test/fixtures/prompts/simple_maths_1.yml --provider openai --model gpt-3.5-turbo])
        expected_output = <<~OUTPUT
          ---
          system_prompt: I like to solve maths problems.
          llm:
            provider: openai
            model: gpt-3.5-turbo
          messages:
          - role: user
            content: What is 2+2?
          - role: assistant
            content: 2 + 2 = 4
        OUTPUT
        assert_output(expected_output) { cli_run }
      end
    end

    def test_override_model_only
      VCR.use_cassette("run_command/simple_maths_groq_llama3_8b") do
        @cli.parse(%w[--conversation test/fixtures/prompts/simple_maths_1.yml --model llama3-8b-8192])
        expected_output = <<~OUTPUT
          ---
          system_prompt: I like to solve maths problems.
          llm:
            provider: groq
            model: llama3-8b-8192
          messages:
          - role: user
            content: What is 2+2?
          - role: assistant
            content: That's an easy one! The answer is... 4!
        OUTPUT
        assert_output(expected_output) { cli_run }
      end
    end

    private

    def expected_simple_maths_groq_llama3_7b
      <<~OUTPUT
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
    end
  end
end
