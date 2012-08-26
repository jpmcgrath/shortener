# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require 'shortener_mongoid'
require 'database_cleaner'
require 'mongoid'
require 'mongoid-rspec'
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'shoulda/matchers/integrations/rspec'
require 'debugger'

Rails.backtrace_cleaner.remove_silencers!

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.include Mongoid::Matchers
  # Other things
  Mongoid.load!(File.expand_path("../dummy/config/mongoid.yml", __FILE__), :test)
  # Clean up the database
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.orm = "mongoid"
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end
end
