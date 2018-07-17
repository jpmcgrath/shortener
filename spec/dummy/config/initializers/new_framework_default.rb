# This file extends the new Rails (aka version 5) framework default initializers.
# It sets the application defaults therefore and because of this dummy application
# supports new version should contain this file.
# It isn't adding all defaults as the rails 5 does because of 5.1 and 5.2
# contains different settings, therefore, it is scoping the settings that this gem
# requires.
if ActiveRecord::VERSION::MAJOR >= 5
  # Require `belongs_to` associations by default. Previous versions had false.
  Rails.application.config.active_record.belongs_to_required_by_default = true
end

