require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  fixtures [
    :organization_,
    :groups_orgs,
    :users_orgs,
    :usergroup,
    :role_,
    :classname_
  ]

  def setup
    @groups = Group.find :all
    assert !@groups.empty?, "No groups"

    @company = Company.first
    flunk 'No company!' unless @company
  end

  def test_create_group
    user = @company.administrators.first
    flunk 'No user!' unless user

    # Type Group
    group = Group.create(
      :name          => 'Test',
      :company       => @company,
      :creatoruserid => user.id
    )
    assert_not_nil group

    assert_equal @company, group.company
    assert_equal user.id, group.creatoruserid
    assert_equal 0, group.classnameid
    assert_equal 0, group.classpk
    assert_equal 1, group.type_ # open

    rc = group.resource_code(4)
    assert_not_nil rc
    r = Resource.find(:first, :conditions => "codeid=#{rc.id} AND primkey='#{group.id}'")
    assert_not_nil r

    group.class.actions.each do |actionid|
      p = Permission.find(:first,
        :conditions => "companyid=#{group.companyid} AND actionid='#{actionid}' AND resourceid=#{r.id}")
      assert_not_nil p

      # Permissions to administrators
      group.company.administrators.each do |user|
        assert user.permissions.include?(p)
      end
    end
  end

  def test_create_user_group
    user = User.first
    flunk 'No user!' unless user

    # Type User
    group = Group.create(
      :company       => user.company,
      :creatoruserid => user.id,
      :classnameid   => Classname.find_by_value(User.liferay_class).id,
      :classpk       => user.id,
      :friendlyurl   => '/'+user.screenname
    )

    assert_not_nil group

    assert_equal user.companyid, group.companyid
    assert_equal user.id, group.creatoruserid
    assert_equal Classname.find_by_value(User.liferay_class).id, group.classnameid
    assert_equal user.id, group.classpk
    assert_equal 0, group.parentgroupid
    assert_equal 0, group.livegroupid
    assert_equal 0, group.type_
    assert_equal '/'+user.screenname, group.friendlyurl
    assert group.is_active?

    assert_not_nil group.public_layoutset
    assert_not_nil group.private_layoutset

    group.layoutsets.each do |ls|
      assert_equal user.companyid, ls.companyid
      assert_equal false, ls.logo
      assert_equal 0, ls.logoid
      assert_equal 0, ls.pagecount
    end

  end

  # each group must belong to a company
  def test_company
    @groups.each do |x|
      assert_not_nil x.company
    end
  end

  def test_organizations
    @groups.each do |x|
      x.organizations.each do |org|
        assert_not_nil org
      end
    end
  end

  def test_roles
    @groups.each do |x|
      x.roles.each do |role|
        assert_not_nil role
      end
    end
  end

  def test_permissions
    @groups.each do |x|
      x.permissions.each do |permission|
        assert_not_nil permission
      end
    end
  end

  def test_usergroups
    @groups.each do |x|
      x.usergroups.each do |usergroup|
        assert_not_nil usergroup
      end
    end
  end

  # each group must belong to a creator
  def test_creator
    @groups.each do |x|
#       assert !x.creator.nil?, "#{x.id} has no creator"
    end
  end

  # each group must have a friendlyurl
  def test_friendlyurl
    @groups.each do |x|
      assert_not_nil x.friendlyurl
    end
  end

  # each group must have one or more layouts
  def test_layoutsets
    @groups.each do |x|
      assert !x.layoutsets.empty?, "#{x.id} (#{x.name}) has no layoutsets"
      assert !(x.layoutsets.size > 2), "#{x.id} (#{x.name}) has more than 2 layoutsets"
      assert_not_nil x.public_layoutset
      assert_not_nil x.private_layoutset
    end
  end

  def test_members
    @groups.each do |x|
      if x.owner.kind_of?(Organization)
        assert_equal x.owner.members, x.members
      end
    end
  end

  def test_path
    @groups.each do |x|
      if x.private_layouts.any?
        assert_not_nil x.path(:private)
      else
        assert_nil x.path(:private)
      end
      if x.public_layouts.any?
        assert_not_nil x.path(:public)
      else
        assert_nil x.path(:public)
      end
    end
  end

#   def test_resource
#     @groups.each do |x|
# #       assert !x.resource.nil?, "#{x.id} has no resource"
#     end
#   end

end
