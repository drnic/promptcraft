# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "promptcraft"

require "minitest/autorun"
require "minitest/mock"
require "vcr"
require "webmock/minitest"

VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.filter_sensitive_data("<GROQ_API_KEY>") { ENV["GROQ_API_KEY"] }
  config.filter_sensitive_data("<OPENAI_API_KEY>") { ENV["OPENAI_API_KEY"] }
  config.filter_sensitive_data("<OPENROUTER_API_KEY>") { ENV["OPENROUTER_API_KEY"] }
end
