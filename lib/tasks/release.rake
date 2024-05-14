# lib/tasks/homebrew_formula.rake

require "rubygems"
require "rake"

namespace :release do
  task :build_package do
    system "bundle config set cache_all true"
    system "bundle package"
    name = Gem::Specification.load(Dir.glob("*.gemspec").first).name
    version = Gem::Specification.load(Dir.glob("*.gemspec").first).version
    license = Gem::Specification.load(Dir.glob("*.gemspec").first).license
    system "rm -f #{name}*.tar* #{name}*.sha256"
    system "fpm -s dir -t tar --name #{name} --version #{version} --license #{license} --exclude .git --exclude test --exclude spec ."
    system "mv #{name}.tar #{name}-#{version}.tar"
    system "xz -z #{name}-#{version}.tar"
    sha = `shasum -a 256 #{name}-#{version}.tar.xz`.split(" ").first
    File.write("#{name}-#{version}.sha256", sha)
  end

  task :upload_package do
    name = Gem::Specification.load(Dir.glob("*.gemspec").first).name
    version = Gem::Specification.load(Dir.glob("*.gemspec").first).version
    file = "#{name}-#{version}.tar.xz"
    file_sha256 = "#{name}-#{version}.sha256"
    system "gh release create v#{version} #{file} #{file_sha256} --title 'v#{version}' --notes ''"
  end

  desc "Generate Homebrew formula"
  task :generate_homebrew_formula do
    spec = Gem::Specification.load(Dir.glob("*.gemspec").first)
    name = spec.name
    version = spec.version
    sha256sum = File.read("#{name}-#{version}.sha256").strip
    url = `gh release view v#{version} --json assets | jq -r '.assets[] | select(.name == "#{name}-#{version}.tar.xz") | .url'`.strip

    formula_name = spec.name.capitalize
    class_name = formula_name.gsub(/_\w/) { |match| match[1].upcase }.to_s

    formula = <<~RUBY
      class #{class_name} < Formula
        desc "#{spec.summary}"
        homepage "#{spec.homepage}"
        version "#{spec.version}"
        url "#{url}"
        sha256 "#{sha256sum}"

        depends_on "ruby"

        def install
          ENV["GEM_HOME"] = libexec

          # Extract all files to libexec, which is a common Homebrew practice for third-party tools
          libexec.install Dir["*"]

          bin.install libexec/"exe/promptcraft"
          bin.env_script_all_files(libexec/"bin", GEM_HOME: ENV.fetch("GEM_HOME"))
        end

        test do
          # Simple test to check the version or a help command
          system "\#{bin}/promptcraft", "--version"
        end
      end
    RUBY

    Dir.mkdir("tmp") unless Dir.exist?("tmp")
    path = "tmp/#{spec.name.downcase}.rb"
    File.write(path, formula)
    puts "Generated Homebrew formula for #{spec.name} version #{spec.version} at #{path}"
  end
end
