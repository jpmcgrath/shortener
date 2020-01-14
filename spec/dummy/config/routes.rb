Dummy::Application.routes.draw do
  get '/:id' => "shortener/shortened_urls#show"
  root to: "home#show"
end
