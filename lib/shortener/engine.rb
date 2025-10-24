require "rack"
require "rails/engine"
require 'action_dispatch/railtie'
require "voight_kampff"
require "voight_kampff/rails"
require "shortener"

class Shortener::Engine < ::Rails::Engine #:nodoc:
  config.shortener = Shortener
end
