require "rails/railtie"
require "shortener"

class Shortener::Railtie < ::Rails::Railtie #:nodoc:
  initializer "shortener.register.active.record.extension" do
    ActiveSupport.on_load :active_record do
      extend Shortener::ActiveRecordExtension
    end
  end
end
