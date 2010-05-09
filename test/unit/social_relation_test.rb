# encoding: utf-8

require 'test/test_helper'

class SocialRelationTest < ActiveSupport::TestCase
  fixtures [
    :Company,
    :User_,
    :SocialRelation
  ]

  def setup
    @relations = SocialRelation.all
  end

  def test_company
    @relations.each do |x|
      assert_not_nil x.company
    end
  end

  def test_users
    @relations.each do |x|
      assert_not_nil x.user1
      assert_not_nil x.user2
    end
  end

end
