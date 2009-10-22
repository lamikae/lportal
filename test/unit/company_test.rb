require 'test/test_helper'

class CompanyTest < ActiveSupport::TestCase
  fixtures [
    :Company,
    :User_, :Group_,
    :Account_, :Organization_, :Contact_,
    :Layout, :LayoutSet,
    :Resource_, :ResourceCode,
    :Role_, :Users_Roles
  ]

  def setup
    @companies = Company.all
    flunk 'No companies in database!' unless @companies.any?
  end

  # each company must have an account
  def test_account
    @companies.each do |c|
      assert_not_nil c.account, "#{c.id} has no account"
      #assert_equal 0, c.account.send(User.primary_key) #?
    end
  end

  # address is not required, not included in Liferay 5.2.3 dataset
  #   def test_address
  #     @companies.each do |c|
  #       #assert_not_nil c.address, "#{c.id} has no address"
  #     end
  #   end

  def test_contacts
    @companies.each do |c|
      assert !c.contacts.empty?, "#{c.id} has no contacts"
    end
  end

  def test_users
    @companies.each do |c|
      c.users.each do |u|
        assert_not_nil u
      end
    end
  end

  def test_groups
    @companies.each do |c|
      c.groups.each do |g|
        assert_not_nil g
      end
    end
  end

  def test_organizations
    @companies.each do |c|
      c.organizations.each do |o|
        assert_not_nil o
      end
    end
  end

  def test_layoutsets
    @companies.each do |c|
      assert c.layoutsets.any?, 'Company %i has no layoutsets' % c.id
      c.layoutsets.each do |ls|
        assert_equal c, ls.company
      end
    end
  end

#   def test_resources
#     @companies.each do |c|
#       assert c.resources.any?, 'Company %i has no resources' % c.id
#     end
#   end

  def test_administrators
    @companies.each do |c|
      adminrole = Role.find(:first, :conditions => "companyid=#{c.id} AND name='Administrator'")
      assert_not_nil adminrole, 'No admin role found'
      assert c.administrators.size > 0, 'Company %s (%i) does not have administrators' % [c.webid, c.id]
    end
  end

  def test_guest
    @companies.each do |c|
      assert_not_nil c.guest, 'Company %s does not have a guest account' % c.webid
      assert c.guest.is_default?, "No default user for #{c.webid}"
      assert c.guest.is_active?, "Default user account for #{c.webid} is not active"
      assert c.guest.company == c, "Default user for #{c.webid} has wrong company"
      # Liferay 5.2.3 has an account for Guest
      #assert_nil c.guest.account, "Default user for #{c.webid} has an account"
    end
  end

  def test_guest_group
    @companies.each do |c|
      assert_not_nil c.guest_group
    end
  end


  def test_personal_groups
    @companies.each do |c|
      assert_nothing_raised { c.personal_groups }
    end
  end

  def test_public_groups
    @companies.each do |c|
      assert_nothing_raised { c.public_groups }
    end
  end

  def test_open_groups
    @companies.each do |c|
      assert_nothing_raised { c.open_groups }
    end
  end

  def test_private_groups
    @companies.each do |c|
      assert_nothing_raised { c.private_groups }
    end
  end


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

end
