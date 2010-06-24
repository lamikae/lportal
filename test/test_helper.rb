# encoding: utf-8

# Test suite env setup for lportal tests.
# The tests need to talk to the lportal database.
#
### Configure test/database.yml for your setup!
#

require 'test/unit'
require 'yaml'

# Load ActiveRecord
require 'rails_gem_chooser'
rails_gem_version = ENV['RAILS_GEM_VERSION']
RailsGemChooser.__load(rails_gem_version)

# Init database connection
ENV['LPORTAL_ENV'] = 'test'
require 'db_connection'
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.logger.level = Logger::FATAL

require 'test/test_case.rb'

# Load fixtures -- is done automatically
# XXX: Database tables must exist!
=begin
require 'active_record/fixtures'
fixtures_dir = ActiveSupport::TestCase.fixture_path
Dir.glob(File.join(fixtures_dir, '*.{yml,csv}')).each do |fixture_file|
  Fixtures.create_fixtures(File.dirname(fixture_file), File.basename(fixture_file, '.*'))
end
=end

# Load lportal
require File.join(File.dirname(__FILE__),'..','init')

class Test::Unit::TestCase
  include ActiveSupport::Testing::SetupAndTeardown
  include ActiveRecord::TestFixtures
end
