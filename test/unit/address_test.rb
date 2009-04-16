require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  fixtures [:Address, :Company, :User_]

  def setup
    @addresses = Address.all
    flunk 'No addresses found' unless @addresses.any?
  end

  def test_company
    @addresses.each do |x|
      assert_not_nil x.company
    end
  end

  def test_user
    @addresses.each do |x|
      next if x.send(User.primary_key)==0
      assert_not_nil x.user
    end
  end
end
