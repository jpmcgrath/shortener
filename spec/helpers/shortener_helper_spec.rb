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
  end
end
