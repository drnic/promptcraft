# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in promptcraft.gemspec
gemspec

gem "standardrb", "~> 1.0"
gem "faraday", "~> 2.0"

# This patch is required for our use of Ollama for the moment.
gem "langchainrb", github: "patterns-ai-core/langchainrb"
# gem "langchainrb", path: "../langchainrb"
#
# Removes a warning; not required for promptcraft
gem "ruby-openai", github: "drnic/ruby-openai", branch: "remove-warning-no-org"
