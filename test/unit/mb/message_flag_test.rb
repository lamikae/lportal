require 'test/test_helper'

class MB::MessageFlagTest < ActiveSupport::TestCase
  fixtures [
    :User_,
    :MBMessage,
    :MBMessageFlag
  ]

  def setup
    @flags = MB::MessageFlag.all
  end

  def test_user
    @flags.each do |flag|
      assert_not_nil flag.user
    end
  end

  def test_message
    @flags.each do |flag|
      assert_not_nil flag.message
    end
  end

end