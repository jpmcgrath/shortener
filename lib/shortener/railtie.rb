require "mongoid"
require "rails/railtie"
require "shortener"

class Shortener::Railtie < ::Rails::Railtie #:nodoc:
  initializer "load ShortenerHelper " do
    ActiveSupport.on_load :action_view do
      include Shortener::ShortenerHelper
    end
  end
end
