require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  fixtures :Contact_, :Account_, :User_, :Company

  def setup
    @contacts = Contact.all
    assert !@contacts.empty?, "No contacts found"
  end

  def test_company
    @contacts.each do |c|
      assert_not_nil c.company
    end
  end

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
