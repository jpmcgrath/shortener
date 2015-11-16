# -*- coding: utf-8 -*-
require 'spec_helper'

describe Shortener::ShortenerHelper, type: :helper do
  describe '#short_url' do
    let(:destination) { Faker::Internet.url }
    before do
      expect(Shortener::ShortenedUrl).to receive(:generate).with(destination, nil).and_return(shortened_url)
    end

    context 'short url was generated' do
      let(:shortened_url) { instance_double('ShortenedUrl', unique_key: '12345') }

      it "shortens the url" do
        expect(helper.short_url(destination)).to eq "http://test.host/12345"
      end
    end

    context 'short url could not be generated' do
      let(:shortened_url) { nil }

      it 'returns the original url' do
        expect(helper.short_url(destination)).to eq destination
      end
    end

    context 'a short url passed in' do
      let(:destination) { shortened_url }
      let(:shortened_url) { instance_double('ShortenedUrl', unique_key: '12345') }

      it "renders the url" do
        expect(helper.short_url(destination)).to eq "http://test.host/12345"
      end
    end

    context 'a default host set' do
      let(:shortened_url) { instance_double('ShortenedUrl', unique_key: '12345') }

      after {
        Shortener.default_host = nil
      }

      it "shortens the url" do
        Shortener.default_host = "http://foo.co"
        expect(helper.short_url(destination)).to eq "http://foo.co/12345"
      end
    end
  end
end
