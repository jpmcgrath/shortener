Rails.application.routes.draw do
  get '/s/:id', :to => 'shortener/shortened_urls#show', :as => 'shortener_translate'
end
