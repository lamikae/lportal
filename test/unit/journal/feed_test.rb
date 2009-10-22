require 'test/test_helper'

class Journal::FeedTest < ActiveSupport::TestCase
  fixtures [
    :Company,
    :User_,
    :Group_,
    :JournalFeed
  ]

  def setup
    @feeds = Journal::Feed.all
  end

  def test_company
    @feeds.each do |x|
      assert_not_nil x.company
    end
  end

  def test_group
    @feeds.each do |x|
      assert_not_nil x.group
    end
  end

  def test_user
    @feeds.each do |x|
      assert_not_nil x.user
    end
  end

end
