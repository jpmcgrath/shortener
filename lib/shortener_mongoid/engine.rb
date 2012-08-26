require "rails/engine"
require "shortener_mongoid"

class Shortener::Engine < ::Rails::Engine #:nodoc:
  config.shortener = Shortener
end
