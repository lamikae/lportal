require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  fixtures [
    :role_,
    :users_roles,
    :groups_roles,
    :permission_,
    :users_permissions,
    :groups_permissions,
    :resource_,
    :resourcecode
  ]

  def setup
    @roles = Role.all
    @company = Company.first
    flunk 'No company!' unless @company
  end

  def test_create
    name = 'Regular role'
    description = 'test'

    role = Role.create(
      :company => @company,
      :name => name,
      :description => description
    )
    role.reload

    assert_equal @company, role.company
    assert_equal name, role.name
    assert_equal description, role.description
    assert_equal 0, role.classnameid
    assert_equal 0, role.classpk
    assert_equal 1, role.type_

    # ResourceCode & Resource
    rc = role.resource_code(1)
    assert_not_nil rc
    r = Resource.find(:first, :conditions => "codeid=#{rc.id} AND primkey='#{role.companyid}'")
    assert_not_nil r

    rc = role.resource_code(4)
    assert_not_nil rc
    r = Resource.find(:first, :conditions => "codeid=#{rc.id} AND primkey='#{role.id}'")
    assert_not_nil r

    role.class.actions.each do |actionid|
      p = Permission.find(:first,
        :conditions => "companyid=#{role.companyid} AND actionid='#{actionid}' AND resourceid=#{r.id}")
      assert_not_nil p

      # Permissions to administrators
      role.company.administrators.each do |user|
        assert user.permissions.include?(p)
      end
    end
  end

  def test_destroy
    Role.all.each do |role|
      rc = role.resource_code(4)

      company = role.company
      users = role.users
      groups = role.groups

      role.destroy

      users.each do |user|
        assert !user.roles.include?(role)
      end

      groups.each do |group|
        assert !group.roles.include?(role)
      end

      assert_raise(ActiveRecord::RecordNotFound) { role.reload }


      next unless rc
      r = Resource.find(:first, :conditions => "codeid=#{rc.id} AND primkey='#{role.id}'")
      next unless r

      %w{
      ASSIGN_MEMBERS
      DEFINE_PERMISSIONS
      DELETE
      MANAGE_ANNOUNCEMENTS
      PERMISSIONS
      UPDATE
      VIEW }.each do |actionid|
        p = Permission.find(:first,
          :conditions => "companyid=#{company.id} AND actionid='#{actionid}' AND resourceid=#{r.id}")
        assert_nil p

        # User + group permissions
        users.each do |user|
          assert !user.permissions.include?(p)
        end
        groups.each do |group|
          assert !group.permissions.include?(p)
        end
      end
      assert_raise(ActiveRecord::RecordNotFound) { r.reload }
    end
  end


  # each role must belong to a company
  def test_company
    @roles.each do |r|
      assert_not_nil r.company, "#{r.id} belongs to no companies"
    end
  end

  def test_users
    @roles.each do |r|
      r.users.each do |user|
        assert_not_nil user
      end
    end
  end

  def test_groups
    @roles.each do |r|
      r.groups.each do |group|
        assert_not_nil group
      end
    end
  end

  def test_permissions
    @roles.each do |r|
      r.permissions.each do |permission|
        assert_not_nil permission
      end
    end
  end

end
