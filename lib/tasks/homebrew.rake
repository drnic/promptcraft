require "rubygems"
require "rake"

namespace :homebrew do
  desc "Generate Homebrew formula"
  task :generate_formula do
    spec = Gem::Specification.load(Dir.glob("*.gemspec").first)

    formula_name = spec.name.capitalize
    class_name = formula_name.gsub(/_\w/) { |match| match[1].upcase }.to_s
    ruby_version = "3.3"
    gem_file = "#{spec.name}-#{spec.version}.gem"
    gem_url = "https://rubygems.org/downloads/#{gem_file}"
    sha256sum = `curl -sL #{gem_url} | shasum -a 256 | cut -d' ' -f1`.strip

    formula = <<~RUBY
      class #{class_name} < Formula
        desc "#{spec.summary}"
        homepage "#{spec.homepage}"
        url "#{gem_url}"
        sha256 "#{sha256sum}"

        depends_on "ruby@#{ruby_version}"

        def install
          libexec = Pathname.new("\#{HOMEBREW_PREFIX}/libexec")
          libexec.install "#{gem_file}", "Gemfile.lock"
          ENV["GEM_HOME"] = libexec
          system "bundle", "install", "--path=\#{libexec}"
          system "gem", "install", libexec/"#{gem_file}"
          bin.write_exec_script Dir["\#{libexec}/bin/*"]
        end
      end
    RUBY

    Dir.mkdir("tmp") unless Dir.exist?("tmp")
    path = "tmp/#{spec.name.downcase}.rb"
    File.write(path, formula)
    puts "Generated Homebrew formula for #{spec.name} version #{spec.version} at #{path}"
  end
end
