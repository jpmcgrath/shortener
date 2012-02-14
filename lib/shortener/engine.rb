require "rails/engine"
require "shortener"

class Shortener::Engine < ::Rails::Engine #:nodoc:
  config.shortener = Shortener
end
