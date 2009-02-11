require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  fixtures :account_

  def setup
    @accounts = Account.find :all
    assert !@accounts.empty?, "No accounts found"
  end

  def test_company
    @accounts.each do |x|
      assert_not_nil x.company
    end
  end

  def test_user
    @accounts.each do |x|
      #assert_not_nil x.user
    end
  end

end
