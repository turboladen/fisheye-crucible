require 'metric_fu'
require 'code_statistics'

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

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  CodeStatistics.new(*STATS_DIRECTORIES).to_s
end