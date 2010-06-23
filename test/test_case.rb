# encoding: utf-8

begin
  require 'active_support/testing/assertions'
rescue
  STDERR.puts 'OOPS'
  raise $!
end

require 'active_support/test_case'

require 'active_record/fixtures'
require 'active_support/dependencies'

# Fixtures patches
case ActiveRecord::Base.connection.adapter_name
when 'PostgreSQL'
  require File.join(File.dirname(__FILE__),'..','active_record','fixtures')
end

# Include fixtures to TestCases
class ActiveSupport::TestCase
  include ActiveRecord::TestFixtures
  self.fixture_path = File.join(
    File.dirname(File.expand_path(__FILE__)),
    'fixtures',
    ActiveRecord::Base.connection.adapter_name
  )
  self.use_instantiated_fixtures  = false
  self.use_transactional_fixtures = true
end
