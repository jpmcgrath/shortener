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

# Patch over Rails 4 -> 5 Migration API changes.
unless ActiveRecord::Migration.respond_to?(:[])
  class ActiveRecord::Migration
    def self.[](*args)
      self
    end
  end
end

# Run any available migration
if ActiveRecord::Migrator.respond_to?(:migrate)
  ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)
else
  ActiveRecord::Base.connection.migration_context.migrate
end
