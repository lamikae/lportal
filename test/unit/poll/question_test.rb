require 'test_helper'

class Poll::QuestionTest < ActiveSupport::TestCase
  fixtures [
    :Company,
    :User_,
    :Group_,
    :PollsQuestion
  ]

  def setup
    @qs = Journal::Feed.all
  end

  def test_company
    @qs.each do |x|
      assert_not_nil x.company
    end
  end

  def test_group
    @qs.each do |x|
      assert_not_nil x.group
    end
  end

  def test_user
    @qs.each do |x|
      assert_not_nil x.user
    end
  end
end
