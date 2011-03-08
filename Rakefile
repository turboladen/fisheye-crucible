require 'rubygems' if RUBY_VERSION < "1.9.0"

begin
  require 'bundler'
rescue LoadError => e
  STDERR.puts e.message
  STDERR.puts "Run `gem install bundler` to install Bundler."
  exit e.status_code
end

begin
  Bundler.setup(:development)
rescue Bundler::BundlerError => e
  STDERR.puts e.message
  STDERR.puts "Run `bundle install` to install missing gems."
  exit e.status_code
end

require 'rake'

# Load all extra rake tasks
Dir['tasks/**/*.rake'].each { |t| load t }

require 'yard'
YARD::Rake::YardocTask.new

require 'ore/specification'
require 'jeweler'
Jeweler::Tasks.new(Ore::Specification.new)


