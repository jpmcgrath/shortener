require "spec_helper"
require File.expand_path("../../../lib/generators/shortener/shortener_generator.rb", __FILE__)

RSpec.describe ShortenerGenerator do
  describe ".next_migration_number" do
    it "returns the next migration number" do
      expect { described_class.next_migration_number(".") }.not_to raise_error
    end
  end
end
