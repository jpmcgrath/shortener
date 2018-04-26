module Shortener::ActiveRecordExtension
  def has_shortened_urls
    has_many :shortened_urls, class_name: "::Shortener::ShortenedUrl", as: :owner
  end
end

if Rails::VERSION::MAJOR < 5 && !ActiveRecord::Migration.respond_to?(:[])
  module VersionedMigrationPatch
    def [](*args)
      ActiveRecord::Migration
    end
  end
  ActiveRecord::Migration.extend VersionedMigrationPatch
end
