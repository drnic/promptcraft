require "test_helper"

module Promptcraft::Cli
  class TestRunCommand < Minitest::Test
    def setup
      @cmd = RunCommand.new
    end

    def test_help
      @cmd.parse(%w[--help])
      assert_output(/Usage:/) { @cmd.run }
    end

    def test_required_options
      @cmd.parse(%w[])
      assert_output(/Option '--conversation' should appear at least 1 time/i) { @cmd.run }
    end
  end
end
