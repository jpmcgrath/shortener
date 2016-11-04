# -*- coding: utf-8 -*-
require 'spec_helper'

describe Shortener::ShortenerHelper, type: :helper do
  describe '#short_url' do
    let(:destination) { Faker::Internet.url }

    context 'without user or custom key' do
      before do
        expect(Shortener::ShortenedUrl).to receive(:generate).with(destination, owner: nil, custom_key: nil, expires_at: nil, fresh: false, category: nil).and_return(shortened_url)
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
    end

    context 'with owner' do
      let(:owner) { double('User') }
      it 'sends user to generate function' do
        expect(Shortener::ShortenedUrl).to receive(:generate).with(destination, owner: owner, custom_key: nil, expires_at: nil, fresh: false, category: nil)
        helper.short_url(destination, owner: owner)
      end
    end

    context 'with custom_key' do
      it 'sends custom key code to generate function' do
        expect(Shortener::ShortenedUrl).to receive(:generate).with(destination, owner: nil, custom_key: 'custkey', expires_at: nil, fresh: false, category: nil)
        helper.short_url(destination, custom_key: 'custkey')
      end
    end

    context 'with expires_at' do
      it 'sends custom key code to generate function' do
        expect(Shortener::ShortenedUrl).to receive(:generate).with(destination, owner: nil, custom_key: nil, expires_at: 'testtime', fresh: false, category: nil)
        helper.short_url(destination, expires_at: 'testtime')
      end
    end

    context 'with category' do
      it 'sends custom key code to generate function' do
        expect(Shortener::ShortenedUrl).to receive(:generate).with(destination, owner: nil, custom_key: nil, expires_at: nil, fresh: false, category: 'testcat')
        helper.short_url(destination, category: 'testcat')
      end
    end

    context 'with url options for https and subdomain' do
      let(:short_url) { double('ShortUrl', unique_key: 'knownkey') }
      it 'sends custom key code to generate function' do
        expect(Shortener::ShortenedUrl).to receive(:generate).and_return(short_url)
        url = helper.short_url(destination, expires_at: 'testtime', url_options: { subdomain: 'foo', protocol: 'https'})
        expect(url).to eq 'https://foo.test.host/knownkey'
      end
    end
  end
end
