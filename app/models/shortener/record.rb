class Shortener::Record < ActiveRecord::Base #:nodoc:
  self.abstract_class = true
end

ActiveSupport.run_load_hooks :shortener_record, Shortener::Record
