# gem_v = ENV['RAILS_GEM_VERSION']
# p gem_v
# RailsGemChooser.__load_gem('activesupport',ENV['RAILS_GEM_VERSION'])

begin
  require 'active_support/testing/assertions'
rescue
  STDERR.puts 'OOPS'
  raise $!
end

require 'active_support/test_case'

require 'active_record/fixtures'
require 'active_support/dependencies'

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
