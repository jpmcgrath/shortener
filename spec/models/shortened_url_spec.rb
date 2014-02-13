# -*- coding: utf-8 -*-
require 'spec_helper'

describe Shortener::ShortenedUrl do
  it { should belong_to :owner }
  it { should validate_presence_of :url }

  shared_examples_for "shortened url" do
    let(:short_url) { Shortener::ShortenedUrl.generate!(long_url, owner) }
    it "should be shortened" do
      short_url.should_not be_nil
      short_url.url.should == expected_long_url
      short_url.unique_key.length.should == 5
      short_url.owner.should == owner
    end
  end

  context "shortened url" do
    let(:long_url) { "http://www.doorkeeperhq.com/" }
    let(:expected_long_url) { long_url }
    let(:owner) { nil }
    it_should_behave_like "shortened url"
  end

  context "shortened url with partial URL" do
    let(:long_url) { "www.doorkeeperhq.com" }
    let(:expected_long_url) { "http://www.doorkeeperhq.com/" }
    let(:owner) { nil }
    it_should_behave_like "shortened url"
  end

  context "shortened url with i18n path" do
    let(:long_url) { "http://www.doorkeeper.jp/%E6%97%A5%E6%9C%AC%E8%AA%9E" }
    let(:expected_long_url) { long_url }
    let(:owner) { nil }
    it_should_behave_like "shortened url"
  end

  context "shortened url with user" do
    let(:long_url) { "http://www.doorkeeperhq.com/" }
    let(:expected_long_url) { long_url }
    let(:owner) { User.create }
    it_should_behave_like "shortened url"
  end

  context "existing shortened URL" do
    before { @existing = Shortener::ShortenedUrl.generate!("http://www.doorkeeperhq.com/") }
    it "should look up exsiting URL" do
      Shortener::ShortenedUrl.generate!("http://www.doorkeeperhq.com/").should == @existing
      Shortener::ShortenedUrl.generate!("www.doorkeeperhq.com").should == @existing
    end
    it "should generate different one for different" do
      Shortener::ShortenedUrl.generate!("www.doorkeeper.jp").should_not == @existing
    end

    context "duplicate unique key" do
      before do
        Shortener::ShortenedUrl.any_instance.stub(:generate_unique_key).
          and_return(@existing.unique_key, "ABCDEF")
      end
      it "should try until it finds a non-dup key" do
        short_url = Shortener::ShortenedUrl.generate!("client.doorkeeper.jp")
        short_url.should_not be_nil
        short_url.unique_key.should == "ABCDEF"
      end
    end
  end

  describe "unexpired scope" do
    subject { described_class.unexpired }

    it "should build correct sql" do
      current_time = Time.current
      Time.stub(:current).and_return(current_time)
      subject.where_values.should have(1).item
      subject.where_values.first.to_sql.should == "(\"shortened_urls\".\"expires_at\" IS NULL OR \"shortened_urls\".\"expires_at\" > '#{current_time.to_s(:db)}')"
    end

    it "should contain permanent and unexpired records" do
      described_class.destroy_all
      permanent_url = described_class.generate("example.com/page1")
      expired_url   = described_class.generate("example.com/page2", nil, expires_at: 2.hour.ago)
      unexpired_url = described_class.generate("example.com/page3", nil, expires_at: 1.hour.since)
      subject.map(&:id).should =~ [permanent_url.id, unexpired_url.id]
    end
  end
end
