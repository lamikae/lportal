# Test suite env setup for lportal tests.
# The tests need to talk to the lportal database.
#
### Configure test/database.yml for your setup!
#

require 'test/unit'
require 'yaml'

# Init database connection
ENV['LPORTAL_ENV'] = 'test'
require 'db_connection'

# Load lportal
require File.join(File.dirname(__FILE__),'..','init')

require 'test/test_case.rb'

class Test::Unit::TestCase
  include ActiveSupport::Testing::SetupAndTeardown
  include ActiveRecord::TestFixtures
end
