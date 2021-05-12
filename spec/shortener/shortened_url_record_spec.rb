require 'spec_helper'

describe Shortener::ShortenedUrl do

  def generate_shortened_link(link, expiration_time)
    Shortener::ShortenedUrl.generate(link, expires_at: expiration_time)
  end

  LINKS = ['https://stackoverflow.com',
           'https://github.com',
           'https://twitter.com',
           'https://reddit.com']

  it "returns a default redirect" do
    expected = { url: Shortener.default_redirect || '/', shortened_url: nil }
    LINKS.each do |link|
      shortened_link = generate_shortened_link(link, Time.now)
      token = shortened_link[:unique_key]
      out = Shortener::ShortenedUrl.fetch_with_token(token: token)
      expect(out).to eq expected
    end
  end
end