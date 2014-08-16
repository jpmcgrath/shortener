require 'spec_helper'

describe "Routes" do
  it 'routes to shortened url' do
    expect(get: 's/abcd').to route_to(
      controller: 'shortener/shortened_urls',
      action: 'translate',
      unique_key: 'abcd'
    )
  end
end