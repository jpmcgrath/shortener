# -*- coding: utf-8 -*-
require 'spec_helper'

describe Shortener::ShortenedUrlsController, type: :controller do
  let(:destination) { Faker::Internet.url }
  let(:short_url) { Shortener::ShortenedUrl.generate(destination) }

  describe '#show' do
    before do
      get :show, id: code
    end

    context 'real code' do
      let(:code) { short_url.unique_key}

      it 'redirects to the destination url' do
        expect(response).to redirect_to destination
      end
    end

    context 'real code with trailing characters' do
      let(:code) { "#{short_url.unique_key}-" }

      it 'redirects to the destination url' do
        expect(response).to redirect_to destination
      end
    end

    context 'wrong code' do
      let(:code) { "wrongcode" }

      it 'redirects to the root url' do
        expect(response).to redirect_to root_url
      end
    end

    context 'code with invalid characters' do
      let(:code) { "-" }

      it 'redirects to the root url' do
        expect(response).to redirect_to root_url
      end
    end
  end
end
