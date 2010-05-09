# encoding: utf-8

require 'test/test_helper'

class MB::DiscussionTest < ActiveSupport::TestCase
  fixtures [
#     :Company,
#     :User_,
#     :Group_,
    :MBCategory,
    :MBDiscussion,
    :MBMessage,
    :MBThread
  ]

  def setup
    @discussions = MB::Discussion.all
  end

  def test_thread
    @discussions.each do |x|
      assert_not_nil x.thread, "#{x.id} belongs to no thread"
    end
  end

end
