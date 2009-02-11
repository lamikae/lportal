require 'test_helper'

class MB::DiscussionTest < ActiveSupport::TestCase
  fixtures [
    :mbcategory,
    :mbdiscussion,
    :mbmessage,
    :mbthread
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
