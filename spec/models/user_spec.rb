# -*- coding: utf-8 -*-
require 'spec_helper'

# user defined in dummy app, uses has_shortened_urls
describe User do
  it { should have_many :shortened_urls }

  context 'shortened url created with owner' do
    let (:user) { User.create }
    let (:url) { Shortener::ShortenedUrl.generate("dealush.com", user) }
    specify 'shorted_urls will contains the url' do
      expect(user.shortened_urls).to include url
      expect(user.shortened_urls.size).to be 1
    end
  end
end
