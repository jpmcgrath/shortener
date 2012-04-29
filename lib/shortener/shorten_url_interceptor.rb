# -*- coding: utf-8 -*-
module Shortener
=begin
The Shorten URL Interceptor is a mail interceptor which shortens any URLs
in generated emails.

Usage:

  class MyMailer < ActionMailer::Base
    register_interceptor Shortener::ShortenUrlInterceptor.new
  end
=end
  class ShortenUrlInterceptor

    DEFAULT_NOT_SHORTEN = [ 'twitter\.com/',
                            'facebook\.com/',
                            'cloudfront\.net/' ].map {|r| Regexp.new(r) }
    DEFAULT_LENGTH_THRESHOLD = 20

    URL_REGEX = /\b((https?):\/\/\w+\.)[-A-Z0-9+&@#\/%?=~_|$!:,.;]*[-A-Z0-9+&@#\/%=~_|$]/i
    MIME_TYPES = %w(text/plain text/html application/xhtml+xml)

    def initialize(opts = {})
      @not_shorten = opts[:not_shorten] || DEFAULT_NOT_SHORTEN
      @length_threshold = opts[:length_threshold] || DEFAULT_LENGTH_THRESHOLD
      @base_url = opts[:base_url] || ShortenUrlInterceptor.infer_base_url
    end

    def delivering_email(email)
      [email, email.all_parts].flatten.compact.each do |part|
        if MIME_TYPES.include?(part.mime_type)
          part.body = part.body.decoded.gsub(URL_REGEX) do |url|
            shorten_url(url)
          end
        end
      end
    end

    protected

    def shorten_url(url)
      if url.length > @length_threshold && ! @not_shorten.any?{|r| r =~ url}
        short_url = Shortener::ShortenedUrl.generate!(url)
        File.join(@base_url, short_url.unique_key)
      else
        url
      end
    rescue => err
      raise err if Rails.env.test?
      Airbrake.notify(err, :url => url) if defined?(Airbrake)
      return url
    end

    def self.infer_base_url
      host = ActionMailer::Base.default_url_options[:host]
      if host.blank?
        raise "Please supply :base_url for ShortenUrlInterceptor or define default_url_options for mailer"
      else
        "http://#{host}/"
      end
    end
  end
end
