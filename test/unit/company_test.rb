require 'test_helper'

class CompanyTest < ActiveSupport::TestCase
  fixtures [
    :company,
    :user_, :group_,
    :account_, :organization_, :contact_,
    :layout, :layoutset,
    :resource_, :resourcecode
  ]


  # each company must have an account
  def test_account
    @companies.each do |c|
      assert !c.account.nil?, "#{c.id} has no account"
    end
  end

  # each company must have contacts
  def test_contacts
    @companies.each do |c|
      assert !c.contacts.empty?, "#{c.id} has no contacts"
    end
  end

  # hmm?
#   def test_defaultuser
#     @companies.each do |c|
#       assert c.account.user.is_default?, "No default user for #{c.id}"
#       assert c.account.user.is_active?, "Default user account for #{c.id} is not active"
#       assert c.account.user.company == c, "Default user for #{c.id} has wrong company"
#       assert !c.account.user.account.nil?, "Default user for #{c.id} has no account"
#     end
#   end

  # each company must have a webid
  def test_webid
    @companies.each do |c|
      assert_not_nil c.webid, "#{c.id} has no webid"
    end
  end

  # each company must have a virtualhost
  def test_virtualhost
    layoutsets_virtualhosts=Web::LayoutSet.find(:all).map{|s| s.virtualhost }
    @companies.each do |c|
      assert_not_nil c.virtualhost, "#{c.id} has no virtualhost"

      # check that the virtualhost isn't duplicated in any layoutsets
      assert !layoutsets_virtualhosts.include?(c.virtualhost), "Duplicate virtualhost #{c.virtualhost} in layoutsets"
    end
  end

#   def test_organizations
#     @companies.each do |c|
#       assert !c.organizations.empty?, "#{c.id} has no organizations"
#     end
#   end

  def test_administrators
    @companies.each do |c|
      assert !c.administrators.empty?, "#{c.id} has no administrators"
    end
  end

  def test_guest
    @companies.each do |c|
      assert_not_nil c.guest
    end
  end

  def test_guest_group
    @companies.each do |c|
      assert_not_nil c.guest_group
    end
  end

end
