# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require 'shortener'
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'
require 'byebug'
require 'faker'
require 'capybara/rspec'

Rails.backtrace_cleaner.remove_silencers!

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Run any available migration
migration_path = File.expand_path("../dummy/db/migrate/", __FILE__)
if ActiveRecord::Migrator.respond_to?(:migrate)
  ActiveRecord::Migrator.migrate(migration_path)
elsif Rails::VERSION::MAJOR < 6
  ActiveRecord::MigrationContext.new(migration_path).migrate
else
  ActiveRecord::MigrationContext.new(migration_path, ActiveRecord::Base.connection.schema_migration).migrate
end
