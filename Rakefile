require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'ruby-lint/rake_task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

task :default => :spec
task :test => :spec

desc 'Run RuboCop on the lib directory'
Rubocop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['lib/**/*.rb']
  # don't abort rake on failure
  task.fail_on_error = false
end

RubyLint::RakeTask.new do |task|
  task.name  = 'lint'
  task.files = ['lib']
end

desc 'Runs specs/Lint/Style checks'
task :all => [ :lint, :rubocop, :spec ]