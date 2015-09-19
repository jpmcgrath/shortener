# -*- coding: utf-8 -*-
require 'spec_helper'

describe Shortener::ShortenedUrlsController, type: :controller do
  let(:destination) { Faker::Internet.url }
  let(:short_url)   { Shortener::ShortenedUrl.generate(destination) }

  describe '#show' do
    before do
      get :show, id: key
    end

    context 'valid keys' do
      context 'real key' do
        let(:key) { short_url.unique_key }

        it 'redirects to the destination url' do
          expect(response).to redirect_to destination
        end
      end

      context 'real key with trailing characters' do
        let(:key) { "#{short_url.unique_key}-" }

        it 'redirects to the destination url' do
          expect(response).to redirect_to destination
        end
      end
    end

    context 'invalid keys' do
      context 'non existant key' do
        let(:key) { "nonexistantkey" }

        it 'redirects to the root url' do
          expect(response).to redirect_to root_url
        end
      end

      context 'key with invalid characters' do
        let(:key) { "-" }

        it 'redirects to the root url' do
          expect(response).to redirect_to root_url
        end
      end

      context "custom default redirect set" do
        before do
          Shortener.default_redirect = 'http://www.default_redirect.com'
          # call again for the get is done with the setting
          get :show, id: key
        end

        context 'non existant key' do
          let(:key) { "nonexistantkey" }

          it 'redirects to the root url' do
            expect(response).to redirect_to 'http://www.default_redirect.com'
          end
        end

        context 'key with invalid characters' do
          let(:key) { "-" }

          it 'redirects to the root url' do
            expect(response).to redirect_to 'http://www.default_redirect.com'
          end
        end
      end

      context 'expired code' do
        let(:expired_url) { Shortener::ShortenedUrl.generate(Faker::Internet.url, expires_at: 1.hour.ago) }
        describe "GET show with expired code" do
          let(:key) { expired_url.unique_key }
          it 'redirects to the default url' do
            expect(response).to redirect_to Shortener.default_redirect
          end
        end
      end
    end
  end
end
