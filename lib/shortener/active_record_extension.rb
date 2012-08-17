module Shortener::ActiveRecordExtension
  def has_shortened_urls
    has_many :shortened_urls, :class_name => "::Shortener::ShortenedUrl", :as => :owner
  end
end
