# -*- coding: utf-8 -*-
require 'spec_helper'

shared_examples_for "good code" do
  it "redirects to actual url" do
    get :show, :id => code
    response.should redirect_to("http://www.doorkeeperhq.com/")
  end
end

shared_examples_for "wrong code" do
  it "redirects to actual url" do
    get :show, :id => code
    response.should redirect_to("/")
  end
end

describe Shortener::ShortenedUrlsController do
  let(:long_url) { "www.doorkeeperhq.com" }
  let(:short_url) { Shortener::ShortenedUrl.generate(long_url) }

  describe "GET show with actual code" do
    let(:code) { short_url.unique_key}
    it_should_behave_like "good code"
  end

  describe "GET show with good code but trailing characters" do
    let(:code) { "#{short_url.unique_key}-" }
    it_should_behave_like "good code"
  end

  describe "GET show with wrong code" do
    let(:code) { "testing" }
    it_should_behave_like "wrong code"
  end

  describe "GET show with code of invalid characters" do
    let(:code) { "-" }
    it_should_behave_like "wrong code"
  end

  describe 'maintaing query parameters' do
    context 'without existing query params' do
      it "adds new query params" do
        get :show, :id => short_url.unique_key, :utm_medium => 'large', :utm_source => 'ketchup'
        response.should redirect_to("http://www.doorkeeperhq.com/?utm_medium=large&utm_source=ketchup")
      end
    end

    context "with existing query params" do
      let(:long_url) { "http://www.doorkeeperhq.com?monkey=tennis" }

      it "adds query params" do
        get :show, :id => short_url.unique_key, :utm_medium => 'large', :utm_source => 'ketchup'
        response.should redirect_to("http://www.doorkeeperhq.com/?monkey=tennis&utm_medium=large&utm_source=ketchup")
      end
    end
  end
end
