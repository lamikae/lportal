require 'test_helper'

class MB::ThreadTest < ActiveSupport::TestCase
  fixtures [
    :mbcategory,
    :mbdiscussion,
    :mbmessage,
    :mbthread
  ]

  def setup
    @threads = MB::Thread.all
  end

  def test_category
    @threads.each do |x|
      assert_not_nil x.category, "#{x.id} belongs to no category"
    end
  end

  def test_root
    @threads.each do |x|
      assert_not_nil x.rootmessage, "#{x.id} has no root message"
    end
  end


end
