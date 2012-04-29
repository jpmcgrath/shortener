# -*- coding: utf-8 -*-
require 'spec_helper'
require 'mail'

describe Shortener::ShortenUrlInterceptor do

  def create_email(body)
    Mail.new(:from => 'test@mbln.jp', :to => 'test@mbln.jp', :body => body).tap do |m|
      m.encoded
      Shortener::ShortenUrlInterceptor.new.delivering_email(m)
    end
  end

  TEXTS = [ "Test with URL: %{url}",
            "Test with URL: %{url}!",
            "Test with URL: %{url}, hu!",
            "Test with URL: %{url}. hu!",
            "Test with URL: <a href='%{url}'>test</a>",
            "Test with URL: <a href=\"%{url}\">test</a>" ]
  
  shared_examples_for "shortens URL in text" do |url|
    TEXTS.each do |raw_email_body_text|
      email_body_text = raw_email_body_text % {:url => url}
      it("shortens for #{email_body_text}") do
        email = create_email(email_body_text)
        short_url = Shortener::ShortenedUrl.find_by_url(url)
        short_url.should_not be_nil
        email.body.should == (raw_email_body_text % {:url => "http://mbln.jp/#{short_url.unique_key}"})
      end
    end
  end

  shared_examples_for "does not shorten URL" do |url|
    TEXTS.each do |raw_email_body_text|
      email_body_text = raw_email_body_text % {:url => url}
      it("keeps URL for #{email_body_text}") do
        email = create_email(email_body_text)
        short_url = Shortener::ShortenedUrl.find_by_url(url)
        short_url.should be_nil
        email.body.should == email_body_text
      end
    end
  end

  [ "http://client.doorkeeper.jp/events/124-title",
    "http://client.doorkeeper.jp/events/124-",
    "http://client.doorkeeper.jp/events/124-title?auth_token=xabagangs",
    "http://client.doorkeeper.jp/events/124-%E4%F6%A0",
  ].each do |url|
    it_should_behave_like "shortens URL in text", url
  end

  # we won't shorten certain URLs:
  [ "http://t.co/asdvk",                  # short URL
    "http://twitter.com/doorkeeper_app",  # twitter URL
    "http://facebook.com/doorkeeper_app", # facebook URL
    "http://d1dqic1fklzs1z.cloudfront.net/assets/doorkeeper_group_normal-3a3292fd09e39a70084c247aef60cba9.gif" # asset URL
  ].each do |url|
    it_should_behave_like "does not shorten URL", url
  end    

end
