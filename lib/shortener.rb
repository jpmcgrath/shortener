require "active_support/dependencies"

module Shortener

  autoload :ActiveRecordExtension, "shortener/active_record_extension"
  autoload :ShortenUrlInterceptor, "shortener/shorten_url_interceptor"

  CHARSETS = {
    alphanum: ('a'..'z').to_a + (0..9).to_a,
    alphanumcase: ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a
  }

  # default key length: 5 characters
  mattr_accessor :unique_key_length
  self.unique_key_length = 5

  # character set to chose from:
  #  :alphanum     - a-z0-9     -  has about 60 million possible combos
  #  :alphanumcase - a-zA-Z0-9  -  has about 900 million possible combos
  mattr_accessor :charset
  self.charset = :alphanum

  #The default redirection url when the key isn't found
  mattr_accessor :default_redirect
  self.default_redirect = '/'

  # forbidden keys
  mattr_accessor :forbidden_keys
  self.forbidden_keys = []

  def self.key_chars
    CHARSETS[charset]
  end
end

# Require our railtie and engine
require "shortener/railtie"
require "shortener/engine"
