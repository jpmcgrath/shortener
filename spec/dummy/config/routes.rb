Dummy::Application.routes.draw do
  get '/:id' => "shortener/shortened_urls#show"
  root :to => "application_controller#show"
end
