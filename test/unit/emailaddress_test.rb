require 'test_helper'

class EmailaddressTest < ActiveSupport::TestCase
  fixtures [
    :Company,
    :User_,
    :EmailAddress
  ]

  def setup
    @addrs = Emailaddress.all
    flunk 'No addresses to test' unless @addrs.any?
  end

  def test_company
    @addrs.each do |x|
      assert_not_nil x.company
    end
  end

  def test_user
    @addrs.each do |x|
      assert_not_nil x.user
    end
  end
end
