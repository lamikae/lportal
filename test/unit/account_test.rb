require 'test/test_helper'

class AccountTest < ActiveSupport::TestCase
  fixtures [:Account_, :Company, :User_]

  def setup
    @accounts = Account.find :all
    flunk 'No accounts found' unless @accounts.any?
  end

  def test_company
    @accounts.each do |x|
      assert_not_nil x.company
    end
  end

  def test_user
    @accounts.each do |x|
      next if x.send(User.primary_key)==0
      assert_not_nil x.user, 'Account %i belongs to no user' % x.id
    end
  end

end
