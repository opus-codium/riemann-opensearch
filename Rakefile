# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

task default: %i[standard spec]

require "github_changelog_generator/task"

GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  config.user = "opus-codium"
  config.project = "riemann-opensearch"
  config.exclude_labels = ["skip-changelog"]
  config.future_release = "v#{Riemann::Tools::Opensearch::VERSION}"
end
