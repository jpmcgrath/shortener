require "rails/engine"
require "shortener"

module Shortener
  
  class ShortenerEngine < Rails::Engine
 
    # include the shortener helper methods in the base helper so that
    # they can be accessed everywhere
   # initializer 'shortener.helper' do |app|  
   #   ActionView::Base.send :include, ShortenerHelper
   # end
    
  end
  
end