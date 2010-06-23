# encoding: utf-8

require 'test/test_helper'

class SocialActivityTest < ActiveSupport::TestCase
  fixtures [
    :Company,
    :User_,
    :Group_,
    :SocialActivity
  ]

  def setup
    @activities = SocialActivity.all
  end

  def test_company
    @activities.each do |x|
      assert_not_nil x.company
    end
  end

  def test_group
    @activities.each do |x|
      assert_not_nil x.group
    end
  end

  def test_user
    @activities.each do |x|
      assert_not_nil x.user
    end
  end

end
