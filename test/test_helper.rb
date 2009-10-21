require 'rails_gem_chooser'
RailsGemChooser.__load_gem('activerecord','2.3.4')
RailsGemChooser.__load_gem('activesupport','2.3.4')

require 'active_record/fixtures'

class ActiveSupport::TestCase

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

end
