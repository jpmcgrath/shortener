Rails.application.routes.draw do
  get '/s/:unique_key', :to => 'shortener/shortened_urls#show', :as => 'shortener_translate'
end
