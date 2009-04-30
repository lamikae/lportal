require 'test_helper'

class CaleventTest < ActiveSupport::TestCase
  fixtures  [
    :Company,
    :User_,
    :Group_,
    :CalEvent
  ]

  def setup
    @events = Calevent.all
  end

  def test_company
    @events.each do |x|
      assert_not_nil x.company, "#{x.id} belongs to no company"
    end
  end

  def test_user
    @events.each do |x|
      assert_not_nil x.user, "#{x.id} belongs to no user!"
    end
  end

  def test_group
    @events.each do |x|
      assert_not_nil x.group
    end
  end

end