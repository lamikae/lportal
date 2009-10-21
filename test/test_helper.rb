ENV["RAILS_ENV"] = "test"

# Load Rails
require 'rails_gem_chooser'
RailsGemChooser.__load_gem('activerecord','2.3.4')
RailsGemChooser.__load_gem('activesupport','2.3.4')
require 'active_record/fixtures'

# Open database connection
database_configuration = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection(database_configuration['test'])

# Load lportal
require File.join('..','init')

class ActiveSupport::TestCase

  include ActiveRecord::TestFixtures
  self.fixture_path = File.join(
    File.dirname(File.expand_path(__FILE__)),
    'fixtures'
    )
  self.use_instantiated_fixtures  = false
  self.use_transactional_fixtures = true

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

end
