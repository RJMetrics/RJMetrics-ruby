require 'rake'

task :default => [:build]

task :build do
  `gem uninstall rjmetrics-client`
  `gem build rjmetrics_client.gemspec`
  `gem install rjmetrics-client-0.1.0.gem`
end

