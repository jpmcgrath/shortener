# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require 'shortener'
require 'debugger'
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'shoulda/matchers/integrations/rspec'

Rails.backtrace_cleaner.remove_silencers!

# Run any available migration
