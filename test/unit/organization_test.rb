# encoding: utf-8

require 'test/test_helper'

class OrganizationTest < ActiveSupport::TestCase
  fixtures [
    :Company,
    :Group_,
    :User_,
    :Organization_,
    :Groups_Orgs,
    :Users_Groups,
    :Users_Orgs,
    :ClassName_,
    :ListType
  ]

  def setup
    @orgs = Organization.all
    flunk 'No organizations to test' unless @orgs.any?
  end

  # each organization must belong to a company
  def test_company
    @orgs.each do |x|
      assert_not_nil x.company
    end
  end

  def test_users
    flunk mysql_bug if defined?(mysql_bug)

    @orgs.each do |x|
      assert_not_nil x.users
    end
  end

  def test_parent
    flunk mysql_bug if defined?(mysql_bug)

    @orgs.each do |x|
      assert_not_nil x.parent unless x.parentorganizationid == 0
    end
  end

  def test_root
    assert_not_nil Organization.find_by_parentorganizationid(0), 'No root organization'
  end

  def test_group
    flunk mysql_bug if defined?(mysql_bug)

    @orgs.each do |x|
      group = x.hive
      assert_not_nil group, "#{x.id} does not have a personal group"

      _class = Classname.find_by_value x.liferay_class
      assert_not_nil _class
      assert_equal _class.id, group.classnameid, "#{x.id}'s personal group is not assigned to #{x.liferay_class}"

      assert group.is_active?, "#{x.id}'s personal group is not active"

      # there has to be layoutsets
      assert !group.layoutsets.empty?, "#{x.id}'s personal group does not have layoutsets"
    end
  end

  # each member have to belong to the same company than the organization
  def test_members_companies
    @orgs.each do |org|
      org.members.each do |user|
        assert user.company == org.company, "Member #{user.id} of organization #{org.id} does not belong to company #{org.company.id}"
      end
    end
  end

  def test_status
    flunk mysql_bug if defined?(mysql_bug)

    @orgs.each do |x|
      assert_not_nil x.status
    end
  end

end
