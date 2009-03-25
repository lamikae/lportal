require 'test_helper'

class ReleaseTest < ActiveSupport::TestCase
  fixtures :Release_

  def test_releases
    releases = Release.all
    assert_not_nil releases
    assert !releases.empty?, 'No releases found'
  end

  def test_current
    assert_not_nil Release.current
  end

  def test_schema_version
    assert_equal Release.current.buildNumber, Lportal::Schema.buildnumber
    assert_equal Fixnum, Release.current.buildNumber.class

    Lportal::Schema.buildnumber = 5100
    assert_equal 5100, Lportal::Schema.buildnumber
    assert_equal '5.1.0', Lportal::Schema.version
  end

end
