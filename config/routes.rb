Rails.application.routes.draw do
  get '/s/:unique_key', :to => 'shortener/shortened_urls#translate', :as => 'shortener_translate'
end
