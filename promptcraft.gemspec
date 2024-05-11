# frozen_string_literal: true

require_relative "lib/promptcraft/version"

Gem::Specification.new do |spec|
  spec.name = "promptcraft"
  spec.version = Promptcraft::VERSION
  spec.authors = ["Dr Nic Williams"]
  spec.email = ["drnicwilliams@gmail.com"]

  spec.summary = "Try out new system prompts on your existing AI conversations. Over and over until you're happy."
  spec.description = "The promptcraft CLI let's you replay a conversation between a user and an AI assistant, but with a new system prompt."
  spec.homepage = "https://github.com/drnic/promptcraft"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/drnic/promptcraft"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "concurrent-ruby"
  spec.add_dependency "langchainrb"
  spec.add_dependency "faraday"
  spec.add_dependency "ruby-openai"

  spec.add_dependency "tty-option"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "vcr", "~> 6.0"
  spec.add_development_dependency "webmock", "~> 3.0"
end
