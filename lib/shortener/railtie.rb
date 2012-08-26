require "rails/railtie"
require "shortener"

class Shortener::Railtie < ::Rails::Railtie #:nodoc:
  initializer "shortener.initialize" do
    ActiveSupport.on_load :action_view do
      include Shortener::ShortenerHelper
    end

    config.before_initialize do
      ::Mongoid::Document.module_eval do
        def self.included(base)
          base.extend Shortener::MongoidExtension
        end
      end
    end if defined?(Mongoid)
  end
end
