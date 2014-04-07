require 'rake'

task :default => [:build]

desc "Build Gem with development dependencies"
task :build do
  system("gem uninstall rjmetrics-client")
  system("gem build rjmetrics_client.gemspec")
  system("gem install rjmetrics-client --development")
end

desc "Run RSpec unit tests"
task :test do
  system("rspec test/client_spec.rb --format nested")
end

desc "Generate docs"
task :doc do
  system("yardoc")
end
