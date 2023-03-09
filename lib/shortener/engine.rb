require "rails/engine"
require "browser"
require "shortener"

class Shortener::Engine < ::Rails::Engine #:nodoc:
  config.shortener = Shortener
  Browser::Bot.matchers << ->(ua, _browser) { ua.match?(/Rails Testing/i) }
end
