require "rails/engine"
require "voight_kampff"
require "shortener"

class Shortener::Engine < ::Rails::Engine #:nodoc:
  config.shortener = Shortener
end
