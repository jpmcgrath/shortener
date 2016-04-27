# -*- coding: utf-8 -*-
require 'spec_helper'

describe Shortener::ShortenerHelper, type: :helper do
  describe '#short_url' do
    let(:destination) { Faker::Internet.url }
    let(:short_url) { double('ShortUrl', unique_key: 'knownkey') }

    context 'without user or custom key' do
      before do
        expect(Shortener::ShortenedUrl).to receive(:do_generate!)
          .with(destination, owner: nil, custom_key: nil, expires_at: nil,
                fresh: false)
          .and_return(shortened_url)
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
      it 'sends user to do_generate! function' do
        expect(Shortener::ShortenedUrl).to receive(:do_generate!)
          .with(destination, owner: owner, custom_key: nil, expires_at: nil,
                fresh: false)
        helper.short_url(destination, owner: owner)
      end
    end

    context 'with custom_key' do
      it 'sends custom key code to do_generate! function' do
        expect(Shortener::ShortenedUrl).to receive(:do_generate!)
          .with(destination, owner: nil, custom_key: 'custkey', expires_at: nil,
                fresh: false)
        helper.short_url(destination, custom_key: 'custkey')
      end
    end

    context 'with expires_at' do
      it 'sends custom key code to do_generate! function' do
        expect(Shortener::ShortenedUrl).to receive(:do_generate!)
          .with(destination, owner: nil, custom_key: nil,
                expires_at: 'testtime', fresh: false)
        helper.short_url(destination, expires_at: 'testtime')
      end
    end

    context 'with url options for https and subdomain' do
      it 'sends custom key code to do_generate! function' do
        expect(Shortener::ShortenedUrl).to receive(:do_generate!)
          .and_return(short_url)
        url = helper.short_url(destination, expires_at: 'testtime',
                               url_options: { subdomain: 'foo',
                                              protocol: 'https'})
        expect(url).to eq 'https://foo.test.host/knownkey'
      end
    end

    describe '#generate using Shortener#default_shortening_params' do
      let(:full_params) do
        { owner: nil,
          custom_key: 'default_custkey',
          expires_at: 'default_testtime',
          fresh: false,
          url_options: { subdomain: 'bar', protocol: 'http'} }
      end
      let(:partial_params) do
        { fresh: true,
          url_options: { protocol: 'http',
                         host: 'foobar'}  }
      end
      let(:adhoc_params) { Shortener.adhoc_shortening_params }

      shared_examples_for 'URL shortening with default_shortening_params' do
        let(:destination) { Faker::Internet.url }

        before do
          Shortener.default_shortening_params = default_shortening_params
        end

        it 'passes the right url_options to url_for function' do
          expect(Shortener::ShortenedUrl)
            .to receive(:do_generate!)
            .and_return(short_url)
          expect_any_instance_of(ActionView::RoutingUrlFor)
            .to receive(:url_for)
            .with hash_including(params_for_url_for)
          if params_for_short_url
            helper.short_url(destination, params_for_short_url)
          else
            helper.short_url(destination)
          end
        end
      end

      context 'with parameters passed to short_url' do
        let(:passed_params) do
          { owner: double('User', shortened_urls: destination),
            custom_key: 'custkey',
            expires_at: 'testtime',
            fresh: true,
            url_options: { subdomain: 'foo', protocol: 'https'} }
        end

        let(:default_shortening_params) { full_params }
        let(:params_for_short_url)      { passed_params }
        let(:params_for_url_for)        { passed_params[:url_options] }

        it_behaves_like 'URL shortening with default_shortening_params'
      end

      context 'with no parameters passed to short_url function' do
        let(:default_shortening_params) { full_params }
        let(:params_for_short_url)      { nil }
        let(:params_for_url_for)        { default_shortening_params[:url_options] }

        it_behaves_like 'URL shortening with default_shortening_params'
      end

      context 'with parameters missing in call to short_url function' do
        let(:default_shortening_params) { full_params }
        let(:merged_params)             { default_shortening_params.deep_merge(partial_params) }
        let(:params_for_short_url)      { partial_params }
        let(:params_for_url_for)        { merged_params[:url_options] }

        it_behaves_like 'URL shortening with default_shortening_params'
      end

      context 'with partial default parameters' do
        let(:default_shortening_params) { partial_params }
        let(:merged_params)             { adhoc_params.deep_merge(default_shortening_params) }
        let(:params_for_short_url)      { nil }
        let(:params_for_url_for)        { merged_params[:url_options] }

        it_behaves_like 'URL shortening with default_shortening_params'
      end

      context 'with default parameters set to nil' do
        let(:default_shortening_params) { nil }
        let(:params_for_short_url)      { nil }
        let(:params_for_url_for)        { adhoc_params[:url_options] }

        it_behaves_like 'URL shortening with default_shortening_params'
      end
    end
  end
end
