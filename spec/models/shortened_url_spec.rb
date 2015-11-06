# -*- coding: utf-8 -*-
require 'spec_helper'

describe Shortener::ShortenedUrl, type: :model do
  it { is_expected.to belong_to :owner }
  it { is_expected.to validate_presence_of :url }

  describe '#generate!' do

    context 'shortened url record for requested url does not exist' do
      let(:expected_url) { Faker::Internet.url }

      shared_examples_for "shortened url" do
        let(:short_url) { Shortener::ShortenedUrl.generate!(long_url, owner: owner) }
        it 'creates a shortened url record for the url' do
          expect{short_url}.to change{Shortener::ShortenedUrl.count}.by(1)
          expect(short_url.url).to eq expected_url
          expect(short_url.unique_key.length).to eq 5
          expect(short_url.owner).to eq owner
        end
      end

      context 'userless url' do
        let(:owner) { nil }

        context 'shortened url' do
          it_should_behave_like "shortened url" do
            let(:long_url) { expected_url }
          end
        end

        context 'shortened url with relative path' do
          it_should_behave_like "shortened url" do
            let(:long_url) { Faker::Internet.slug }
            let(:expected_url) { "/#{long_url}" }
          end
        end

        context "shortened url with i18n path" do
          it_should_behave_like "shortened url" do
            let(:long_url) { "#{Faker::Internet.url}/%E6%97%A5%E6%9C%AC%E8%AA%9E" }
            let(:expected_url) { long_url }
          end
        end
      end

      context "shortened url with user" do
        it_should_behave_like "shortened url" do
          let(:owner) { User.create }
          let(:long_url) { expected_url }
        end
      end
    end

    context "request a fresh shortened URL" do
      let(:url) { Faker::Internet.url }
      it "shouldn't create duplicate urls" do
        Shortener::ShortenedUrl.generate!(url)
        expect{Shortener::ShortenedUrl.generate!(url)}.not_to change{Shortener::ShortenedUrl.count}
      end

      it "should create a fresh shortened urls" do
        Shortener::ShortenedUrl.generate!(url)
        expect{Shortener::ShortenedUrl.generate!(url, fresh: true)}.to change{Shortener::ShortenedUrl.count}.by(1)
      end
    end

    context "existing shortened URL" do
      let(:url) { Faker::Internet.url }
      let!(:existing_shortened_url) { Shortener::ShortenedUrl.generate!(url) }

      context 'different url from existing' do
        it "generates a new shortened url record for a different url" do
          expect(Shortener::ShortenedUrl.generate!(Faker::Internet.url)).not_to eq existing_shortened_url
        end
      end

      context 'same url as existing' do
        it 'returns the same shortened link record' do
          expect(Shortener::ShortenedUrl.generate!(url)).to eq existing_shortened_url
        end
      end

      context 'same url as existing, but with a different owner' do
        let(:owner) { User.create }
        it 'returns the a new shortened link record' do
          expect(Shortener::ShortenedUrl.generate!(url, owner: owner)).not_to eq existing_shortened_url
        end
      end

      context 'existing shortened url as argument' do
        let(:owner) { User.create }
        it 'returns the a new shortened link record' do
          expect(Shortener::ShortenedUrl.generate!(existing_shortened_url)).to eq existing_shortened_url
        end
      end

      context 'existing shortened url as argument, with new owner' do
        let(:owner) { User.create }
        it 'returns the a new shortened link record' do
          expect(Shortener::ShortenedUrl.generate!(existing_shortened_url, owner: owner)).not_to eq existing_shortened_url
        end
      end

      context "duplicate unique key" do
        before do
          expect_any_instance_of(Shortener::ShortenedUrl).to receive(:generate_unique_key).
            and_return(existing_shortened_url.unique_key, 'ABCDEF')
          Shortener::ShortenedUrl.where(unique_key: 'ABCDEF').delete_all
        end
        it 'should try until it finds a non-dup key' do
          short_url = Shortener::ShortenedUrl.generate!(Faker::Internet.url)
          expect(short_url).not_to be_nil
          expect(short_url.unique_key).to eq "ABCDEF"
        end
      end
    end

    context "existing shortened URL with relative path" do
      let(:path) { Faker::Internet.slug }
      let!(:existing_shortened_url) { Shortener::ShortenedUrl.generate!(path) }

      context 'same relative path' do
        it 'finds the shortened url from slashless oath' do
          expect(Shortener::ShortenedUrl.generate!(path)).to eq existing_shortened_url
        end
        it "should look up exsiting URL" do
          expect(Shortener::ShortenedUrl.generate!("/#{path}")).to eq existing_shortened_url
        end
      end
    end
  end

  describe '#generate' do
    context 'cannot generate a unique key' do
      before do
        expect(Shortener::ShortenedUrl).to receive(:generate!).and_raise(ActiveRecord::RecordNotUnique.new(nil))
      end
      it 'returns nil' do
        expect(Shortener::ShortenedUrl.generate(Faker::Internet.url)).to eq nil
      end
    end
  end

  describe 'unexpired scope' do
    let(:permanent_url)   { described_class.generate(Faker::Internet.url) }
    let!(:expired_url)     { described_class.generate(Faker::Internet.url, expires_at: 2.hour.ago) }
    let!(:unexpired_url)   { described_class.generate(Faker::Internet.url, expires_at: 1.hour.since) }
    let!(:unexpired_scope)  { described_class.unexpired }

    it "should contain permanent and unexpired records" do
      expect(unexpired_scope).to     include(permanent_url)
      expect(unexpired_scope).to     include(unexpired_url)
      expect(unexpired_scope).not_to include(expired_url)
    end
  end

  describe '#increment_use_count' do
    let(:url) { 'https://example.com'}
    let(:short_url) { Shortener::ShortenedUrl.generate!(url) }
    it 'increments the use_count on the shortenedLink' do
      original_count = short_url.use_count
      short_url.increment_usage_count
      sleep 0.001
      expect(short_url.use_count).to eq (original_count + 1)
    end
  end

  describe '#merge_params_to_url' do
    context 'without params on original url' do
      let(:url) { 'https://example.com'}

      context 'no additional params' do
        let(:params) { nil }

        it 'returns the original url' do
          expect(Shortener::ShortenedUrl.merge_params_to_url(url: url, params: params)).to eq 'https://example.com'
        end
      end

      context 'additional params' do
        let(:params) { {foo: 'bar', hello: 'world' } }

        it 'merges the params to create a new url' do
          expect(Shortener::ShortenedUrl.merge_params_to_url(url: url, params: params)).to eq 'https://example.com?foo=bar&hello=world'
        end
      end
    end

    context 'with params on original url' do
      let(:url) { 'http://example.com/pathname?different=yes&foo=test'}

      context 'no additional params' do
        let(:params) { nil }

        it 'returns the original url' do
          expect(Shortener::ShortenedUrl.merge_params_to_url(url: url, params: params)).to eq 'http://example.com/pathname?different=yes&foo=test'
        end
      end

      context 'additional params' do
        let(:params) { {foo: 'manchoo', hello: 'world' } }

        it 'merges the params to create a new url with the new params taking preceedence' do
          expect(Shortener::ShortenedUrl.merge_params_to_url(url: url, params: params)).to eq 'http://example.com/pathname?different=yes&foo=manchoo&hello=world'
        end
      end
    end
  end

  describe '#fetch_with_token' do
    shared_examples_for 'invalid token supplied' do
      context 'default_path set' do
        it 'returns the default_redirect url, but no shortened url' do
          Shortener.default_redirect = "/default_path"
          result = Shortener::ShortenedUrl.fetch_with_token(token: nil)
          expect(result[:url]).to eq '/default_path'
          expect(result[:shortened_url]).to eq nil
        end
      end
      context 'no default_path set' do
        it 'returns the root path, but no shortened url' do
          Shortener.default_redirect = nil
          result = Shortener::ShortenedUrl.fetch_with_token(token: nil)
          expect(result[:url]).to eq '/'
          expect(result[:shortened_url]).to eq nil
        end
      end
    end

    context 'invalid token' do
      it_should_behave_like 'invalid token supplied' do
        let(:token) { 'invalid_token'}
      end
    end

    context 'valid token' do
      let(:url) { Faker::Internet.url }

      context 'non expired short url' do
        let(:short_url) { Shortener::ShortenedUrl.generate!(url) }
        it 'returns both the url and the shortened url' do
          result = Shortener::ShortenedUrl.fetch_with_token(token: short_url.unique_key)
          expect(result[:url]).to eq url
          expect(result[:shortened_url]).to eq short_url
        end
      end

      context 'expired short url' do
        let(:short_url) { Shortener::ShortenedUrl.generate!(url, expires_at: 1.second.ago) }
        it_should_behave_like 'invalid token supplied' do
          let(:token) { short_url.unique_key }
        end
      end
    end
  end
end
