Dummy::Application.routes.draw do
  match '/:id' => "shortener/shortened_urls#show", via: :get
  root :to => "application_controller#show"
end
