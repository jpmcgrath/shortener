# -*- coding: utf-8 -*-
require 'spec_helper'

describe Shortener::ShortenedUrlsController, type: :controller do
  let(:destination) { Faker::Internet.url }
  let(:short_url)   { Shortener::ShortenedUrl.generate(destination) }

  describe '#show' do
    let(:params) { {} }
    before do
      get :show, { id: key }.merge(params)
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

      context 'parameters on short url' do
        let(:params) { { foo: 34, bar: 49 } }
        let(:key) { short_url.unique_key }

        context 'no parameters on long url' do
          it 'redirects to the destination url with the parmeters' do
            redirect_url_params = Rack::Utils.parse_nested_query(URI.parse(response.location).query)

            expect(redirect_url_params['foo']).to eq '34'
            expect(redirect_url_params['bar']).to eq '49'
            expect(response.code).to eq '301'
          end
        end
        context 'clashing parameters on long url' do
          let(:destination) { "#{Faker::Internet.url}?foo=26&noclash=56" }

          it 'redirects to the destination url with the parmeters on the short url taking priority' do
            redirect_url_params = Rack::Utils.parse_nested_query(URI.parse(response.location).query)

            expect(redirect_url_params['foo']).to     eq '34'
            expect(redirect_url_params['bar']).to     eq '49'
            expect(redirect_url_params['noclash']).to eq '56'
            expect(response.code).to eq '301'
          end
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
