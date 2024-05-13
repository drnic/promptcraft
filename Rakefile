# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"
Dir["#{File.dirname(__FILE__)}/lib/tasks/**/*.rake"].each { |file| load file }

Minitest::TestTask.create

task default: :test
