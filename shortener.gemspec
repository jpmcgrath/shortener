require File.expand_path("../lib/shortener/version", __FILE__)

Gem::Specification.new do |s|
  s.name                      = "shortener_mongoid"
  s.summary                   = "Shortener is a Rails Engine that makes it easy to create shortened URLs for your rails application."
  s.description               = "Shortener is a Rails Engine Gem that makes it easy to create and interpret shortened URLs on your own domain from within your Rails application. Once installed Shortener will generate, store URLS and \"unshorten\" shortened URLs for your applications visitors, all whilst collecting basic usage metrics. This supports Mongoid."
  s.files                     = `git ls-files`.split("\n")
  s.version                   = Shortener::VERSION
  s.platform                  = Gem::Platform::RUBY
  s.authors                   = [ "Kenny Meyer", "James P. McGrath", "Michael Reinsch" ]
  s.email                     = [ "kenny@kennymeyer.net", "gems@jamespmcgrath.com", "michael@mobalean.com" ]
  s.homepage                  = "https://github.com/kennym/shortener_mongoid"
  s.required_rubygems_version = "> 1.3.6"
  s.add_dependency "rails", ">= 3.0.7"
  s.add_dependency "mongoid", ">= 3.0.0"
  s.add_development_dependency "debugger"
  s.add_development_dependency "mongoid-rspec"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "database_cleaner"
  s.executables = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
