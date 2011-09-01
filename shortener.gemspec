require File.expand_path("../lib/shortener/version", __FILE__)

# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name                      = "shortener"
  s.summary                   = "Shortener makes it easy to create shortened URLs for your rails application."
  s.description               = "Shortener is a Rails Engine that allows you to generate and store shortened URLs and serve them up for your own application."
  s.files                     = `git ls-files`.split("\n")
  s.version                   = Shortener::VERSION
  s.platform                  = Gem::Platform::RUBY
  s.authors                   = [ "James P. McGrath" ]
  s.email                     = [ "gems@jamespmcgrath.com" ]
  s.homepage                  = "http://jamespmcgrath.com/projects/shortener"
  s.rubyforge_project         = "shortener"
  s.required_rubygems_version = "> 1.3.6"
  s.add_dependency "activesupport" , ">= 3.0.7"
  s.add_dependency "rails"         , ">= 3.0.7"
  s.executables = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end