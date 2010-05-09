# encoding: utf-8

require 'test/test_helper'

# this test is SLOW
class PermissionTest < ActiveSupport::TestCase
  fixtures [
    :Company,
    :Group_,
    :User_,
    :Permission_,
    :Role_,
    :Roles_Permissions,
    :Users_Permissions,
    :Groups_Permissions
  ]

  def setup
    @permissions = Permission.all
  end

  def test_company
    @permissions.each do |x|
      assert_not_nil x.company, "#{x.id} belongs to no companies"
    end
  end

  def test_resource
    @permissions.each do |p|
      assert_not_nil p.resource, "#{p.id} belongs to no resource!"
    end
  end

  def test_users
    flunk mysql_bug if defined?(mysql_bug)

    @permissions.each do |p|
      assert_not_nil p.users
    end
  end

  def test_roles
    flunk mysql_bug if defined?(mysql_bug)

    @permissions.each do |p|
      assert_not_nil p.roles
    end
  end

  def test_groups
    flunk mysql_bug if defined?(mysql_bug)

    @permissions.each do |p|
      assert_not_nil p.groups
    end
  end

  def test_holders
    flunk mysql_bug if defined?(mysql_bug)

    @permissions.each do |p|
      assert_not_nil p.holders
    end
  end

  def test_rigidity
    flunk mysql_bug if defined?(mysql_bug)

    # each role must exist!
    ActiveRecord::Base.connection.execute(
      "SELECT * from roles_permissions;"
    ).result.each do |res|
      assert Role.find(res[0])
      assert Permission.find(res[1])
    end

    # each user must exist!
    ActiveRecord::Base.connection.execute(
      "SELECT * from users_permissions;"
    ).result.each do |res|
      assert User.find(res[0])
      assert Permission.find(res[1])
    end

    # each group must exist!
    ActiveRecord::Base.connection.execute(
      "SELECT * from groups_permissions;"
    ).result.each do |res|
      assert Group.find(res[0])
      assert Permission.find(res[1])
    end
  end
end
