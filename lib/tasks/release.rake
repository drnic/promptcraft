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
    system "rm -f #{name}.tar* #{name}.sha256"
    system "fpm -s dir -t tar --name #{name} --version #{version} --license #{license} --exclude .git --exclude test --exclude spec ."
    system "xz -z #{name}.tar"
    sha = `shasum -a 256 #{name}.tar.xz`.split(" ").first
    File.write("#{name}.sha256", sha)
  end

  desc "Generate Homebrew formula"
  task :generate_homebrew_formula do
    spec = Gem::Specification.load(Dir.glob("*.gemspec").first)

    formula_name = spec.name.capitalize
    class_name = formula_name.gsub(/_\w/) { |match| match[1].upcase }.to_s
    ruby_version = "3.3"
    gem_file = "#{spec.name}-#{spec.version}.gem"
    gem_url = "https://rubygems.org/downloads/#{gem_file}"
    sha256sum = `curl -sL #{gem_url} | shasum -a 256 | cut -d' ' -f1`.strip
    git_url = spec.metadata["source_code_uri"]  # Fetch the Git URL from gemspec metadata

    formula = <<~RUBY
      class #{class_name} < Formula
        desc "#{spec.summary}"
        homepage "#{spec.homepage}"
        url "#{gem_url}"
        sha256 "#{sha256sum}"
        head "#{git_url}", :branch => "master"  # Default to master branch, adjust if needed

        depends_on "ruby@#{ruby_version}"

        def install
          if build.head?
            # Installation commands for the HEAD version from Git
            system "git", "clone", "#{git_url}", "promptcraft-source"
            Dir.chdir("promptcraft-source") do
              system "bundle", "install"
              system "rake", "install"
            end
          else
            # Installation commands for the stable gem version
            system "gem", "install", "#{gem_file}"
          end
        end
      end
    RUBY

    Dir.mkdir("tmp") unless Dir.exist?("tmp")
    path = "tmp/#{spec.name.downcase}.rb"
    File.write(path, formula)
    puts "Generated Homebrew formula for #{spec.name} version #{spec.version} at #{path}"
  end
end
