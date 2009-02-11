require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  fixtures :contact_, :account_

  def setup
    @contacts = Contact.all
    assert !@contacts.empty?, "No contacts found"
  end

  # each company must have an account
  def test_account
    @contacts.each do |c|
      assert_not_nil c.account, "#{c} has no account"
    end
  end

  def test_user
    @contacts.each do |c|
      assert_not_nil c.user, "#{c} has no user"
    end
  end

end
