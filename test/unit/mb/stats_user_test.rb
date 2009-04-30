require 'test_helper'

class MB::StatsUserTest < ActiveSupport::TestCase
  fixtures [
    :User_,
    :Group_,
    :MBStatsUser
  ]

  def setup
    @stats = MB::StatsUser.all
  end

  def test_user
    @stats.each do |x|
      assert_not_nil x.user
    end
  end

  def test_group
    @stats.each do |x|
      assert_not_nil x.group
    end
  end

end