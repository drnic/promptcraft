# frozen_string_literal: true

require_relative "lib/promptcraft/version"

Gem::Specification.new do |spec|
  spec.name = "promptcraft"
  spec.version = Promptcraft::VERSION
  spec.authors = ["Dr Nic Williams"]
  spec.email = ["drnicwilliams@gmail.com"]

  spec.summary = "Refine and test LLM system prompts"
  spec.description = "PromptCraft is an innovative Ruby tool designed to optimize and test system prompts for AI-powered conversations. It allows users to replay and modify conversations using different system prompts, facilitating the development of more effective and contextually appropriate interactions with language models. Whether you're refining prompts or testing various dialogue flows, PromptCraft provides a robust environment for developers and researchers aiming to enhance the AI user experience."
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

  spec.add_dependency "langchain"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.0"
end
