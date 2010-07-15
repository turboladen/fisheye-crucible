require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/fisheye-crucible'
require 'metric_fu'

Hoe.plugin :newgem
Hoe.plugin :yard
# Hoe.plugin :website
Hoe.plugin :cucumberfeatures
Hoe.plugin :rubyforge

# Gets the description from the main README file
def get_descr_from_readme
  paragraph_count = 0
  File.readlines('README.rdoc', '').each do |paragraph|
    paragraph_count += 1
    if paragraph_count == 4
      return paragraph
    end
  end
end

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'fisheye-crucible' do
  self.summary            = "REST wrapper around Atlassian's Fisheye/Crucible's API"
  self.developer 'Steve Loveless', 'steve.loveless@gmail.com'
  self.post_install_message = File.readlines 'PostInstall.txt'
  self.rubyforge_name       = self.name
  self.version              = FisheyeCrucible::VERSION
  self.url                  = FisheyeCrucible::WWW
  self.description          = get_descr_from_readme
  self.readme_file          = 'README.rdoc'
  self.history_file         = 'History.txt'
  self.rspec_options        = ['--color', '--format', 'specdoc']
  self.extra_dev_deps       += [
    ['rspec'],
    ['yard'],
    ['hoe-yard'],
    ['cucumber']
  ]
  self.test_globs           = 'spec/*.rb'

  # Extra Yard options
  self.yard_title   = "#{self.name} Documentation (#{self.version})"
  self.yard_markup  = :rdoc
  self.yard_opts    += ['--main', self.readme_file]
  self.yard_opts    += ['--output-dir', 'doc']
  self.yard_opts    += ['--private']
  self.yard_opts    += ['--protected']
  self.yard_opts    += ['--verbose']
  self.yard_opts    += ['--files', 
    ['Manifest.txt', 'History.txt']
  ]    
end

#-------------------------------------------------------------------------------
# Overwrite the :clobber_docs Rake task so that it doesn't destroy our docs
#   directory.
#-------------------------------------------------------------------------------
class Rake::Task
  def overwrite(&block)
    @actions.clear
    enhance(&block)
  end
end

Rake::Task[:clobber_docs].overwrite do
end

# Now define the tasks
require 'newgem/tasks'
#Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]

MetricFu::Configuration.run do |config|
  #define which metrics you want to use
  #config.metrics  = [:churn, :flog, :flay, :reek, :roodi, :rcov, :stats]
  config.metrics  = [:churn, :flog, :reek, :roodi, :rcov, :stats]
  #config.graphs   = [:flog, :flay, :reek, :roodi]
  config.graphs   = [:flog, :reek, :roodi]
  config.flay     = { :dirs_to_flay => ['lib/fisheye-crucible'],
                      :minimum_score => 10  } 
  config.flog     = { :dirs_to_flog => ['lib/fisheye-crucible']  }
  config.reek     = { :dirs_to_reek => ['lib/fisheye-crucible']  }
  config.roodi    = { :dirs_to_roodi => ['lib/fisheye-crucible'] }
  config.churn    = { :start_date => "1 year ago", :minimum_churn_count => 10}
  config.rcov     = { :environment => 'test',
                      :test_files => ['spec/*_spec.rb',
                                      'spec/**/*_spec.rb'],
                      :rcov_opts => ["--sort coverage", 
                                     "--no-html", 
                                     "--text-coverage",
                                     "--no-color",
                                     "--profile",
                                     "--exclude /gems/,/Library/"]}
  config.graph_engine = :bluff
end

STATS_DIRECTORIES = [
  %w(Library            lib/),
  %w(Unit\ tests        spec/)
].collect { |name, dir| [ name, "#{dir}" ] }.select { |name, dir| File.directory?(dir) }

begin
  gem 'rails'

  desc "Report code statistics (KLOCs, etc) from the application"
  task :stats do
    require 'code_statistics'
    CodeStatistics.new(*STATS_DIRECTORIES).to_s
  end
rescue LoadError
  puts "Rails is needed in order to check stats."
end

