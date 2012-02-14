Dummy::Application.routes.draw do
  match '/:id' => "shortener/shortened_urls#show"
  root :to => "application_controller#show"
end
