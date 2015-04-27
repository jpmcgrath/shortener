# -*- coding: utf-8 -*-
require 'spec_helper'

shared_examples_for "good code" do
  it "redirects to actual url" do
    get :show, :id => code
    response.should redirect_to("http://www.doorkeeperhq.com/")
  end
end

shared_examples_for "wrong code with default redirect unchanged" do
  it "redirects to default redirect" do
    get :show, :id => code
    response.should redirect_to("/")
  end
end

shared_examples_for "wrong code with custom default redirect" do
  it "redirects to default redirect" do
    get :show, :id => code
    response.should redirect_to("http://www.google.com")
  end
end

describe Shortener::ShortenedUrlsController do
  let(:short_url) { Shortener::ShortenedUrl.generate("www.doorkeeperhq.com") }

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
    it_should_behave_like "wrong code with default redirect unchanged"
  end

  describe "GET show with code of invalid characters" do
    let(:code) { "-" }
    it_should_behave_like "wrong code with default redirect unchanged"
  end

  context "custom default redirect" do
    before do
      Shortener.default_redirect = "http://www.google.com"
    end

    describe "GET show with wrong code" do
      let(:code) { "testing" }
      it_should_behave_like "wrong code with custom default redirect"
    end

    describe "GET show with code of invalid characters" do
      let(:code) { "-" }
      it_should_behave_like "wrong code with custom default redirect"
    end
  end
end
