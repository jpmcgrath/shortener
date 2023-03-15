require "rack"
require "rails/engine"
require "voight_kampff"
require "voight_kampff/rails"
require "shortener"

class Shortener::Engine < ::Rails::Engine #:nodoc:
  config.shortener = Shortener
end
