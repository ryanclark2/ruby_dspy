require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :doc do
  desc "Generate YARD documentation"
  task :generate do
    sh "yard doc"
  end
end