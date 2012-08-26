class User
  include Mongoid::Document

  has_shortened_urls
end
