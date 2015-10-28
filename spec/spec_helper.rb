# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require 'shortener'
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'
require 'byebug'
require 'faker'

Rails.backtrace_cleaner.remove_silencers!

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)
