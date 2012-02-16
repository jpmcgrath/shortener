require File.expand_path("../lib/shortener/version", __FILE__)

# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name                      = "shortener"
  s.summary                   = "Shortener is a Rails Engine that makes it easy to create shortened URLs for your rails application."
  s.description               = "Shortener is a Rails Engine Gem that makes it easy to create and interpret shortened URLs on your own domain from within your Rails application. Once installed Shortener will generate, store URLS and \"unshorten\" shortened URLs for your applications visitors, all whilst collecting basic usage metrics."
  s.files                     = `git ls-files`.split("\n")
  s.version                   = Shortener::VERSION
  s.platform                  = Gem::Platform::RUBY
  s.authors                   = [ "James P. McGrath", "Michael Reinsch" ]
  s.email                     = [ "gems@jamespmcgrath.com", "michael@mobalean.com" ]
  s.homepage                  = "http://jamespmcgrath.com/projects/shortener"
  s.rubyforge_project         = "shortener"
  s.required_rubygems_version = "> 1.3.6"
  s.add_dependency "rails", ">= 3.0.7"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "shoulda-matchers"
  s.executables = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
