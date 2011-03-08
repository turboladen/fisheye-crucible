require 'rspec/core/rake_task'

desc "Run the specs under spec/models"
RSpec::Core::RakeTask.new do |t|
  t.ruby_opts = "-w"
  t.rspec_opts = ['format', 'documentation', '--color']
end
task :default => :spec
