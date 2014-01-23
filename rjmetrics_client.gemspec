Gem::Specification.new do |s|
  s.name        = 'rjmetrics-client'
  s.version     = '0.1.0'
  s.date        = '2014-01-22'
  s.summary     = "RJMetrics Data Import API Client Library"
  s.description = "RJMetrics Data Import API Client Library"
  s.authors     = ["Owen Jones"]
  s.email       = "ojones@rjmetrics.com"
  s.files       = ["lib/rjmetrics_client.rb",
                   "lib/rjmetrics-client/client.rb"]
  s.homepage    = 'http://rjmetrics.com'
  s.license     = 'Apache-2.0'
  s.add_runtime_dependency "rest-client",
    [">= 1.6.7"]
  s.add_runtime_dependency "json",
    [">= 1.7.7"]
  s.add_development_dependency "rspec",
    ["> 0"]
  s.add_development_dependency "yard",
    ["> 0"]
end
