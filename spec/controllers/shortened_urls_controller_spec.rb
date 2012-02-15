# -*- coding: utf-8 -*-
require 'spec_helper'

describe Shortener::ShortenedUrlsController do
  let(:short_url) { Shortener::ShortenedUrl.generate("www.doorkeeperhq.com") }

  describe "GET show with good code" do
    it "redirects to actual url" do
      get :show, :id => short_url.unique_key
      response.should redirect_to("http://www.doorkeeperhq.com/")
    end
  end
  describe "GET show with wrong code" do
    it "redirects to actual url" do
      get :show, :id => "testing"
      response.should redirect_to("/")
    end
  end
end
