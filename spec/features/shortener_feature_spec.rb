require 'spec_helper'

describe Shortener, type: :feature do
  it "includes 'short_url'-helper into public namespace" do
    visit root_path
    expect(page).to have_content(%r{http://www.example.com/[a-zA-Z0-9]{5}})
  end
end
