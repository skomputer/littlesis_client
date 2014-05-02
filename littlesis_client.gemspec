Gem::Specification.new do |s|
  s.name                  = 'littlesis_client'
  s.version               = '0.1.0'
  s.date                  = '2013-03-28'
  s.summary               = "LittleSis API Client"
  s.description           = "A simple library for using the LittleSis API"
  s.authors               = ["Matthew Skomarovsky"]
  s.email                 = 'matthew@verypolite.com'
  s.files                 = ["lib/littlesis_client.rb"] + Dir["lib/littlesis_client/**"]
  s.test_files            = Dir["spec/**spec.rb"]
  s.add_dependency        'activemodel', '>= 3.2.9'
  s.add_dependency        'activesupport', '>= 3.2.9'
  s.add_dependency        'faraday', '>= 0.8.4'
  s.add_dependency        'faraday_middleware', '>= 0.9.0'
  s.add_dependency        'logger', '>= 1.2.8'
  s.required_ruby_version = '>= 1.9.3'
end