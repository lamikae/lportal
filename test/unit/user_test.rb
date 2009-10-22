require 'test/test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures [
    :Address,
    :Company,
    :Phone,
    :Contact_,
    :ClassName_,
    :ListType,
    :LayoutSet,
    :Counter,
    :Role_,
    :ResourceCode,
    :Organization_,
    :Users_Orgs,
    :Group_,
    :Users_Groups
  ]

  def setup
    @users = User.all
    @company = Company.first
    flunk 'No company!' unless @company
  end

  def test_create
    flunk mysql_bug if defined?(mysql_bug)

    firstname = 'Test'
    lastname  = 'User'
    email     = 'test@localhost'
    counter_permission = Counter.find_by_name('com.liferay.portal.model.Permission')
    counter_resource = Counter.find_by_name('com.liferay.portal.model.Resource')

    user = User.create(
      :company => @company,
      :firstname => firstname,
      :lastname => lastname,
      :emailaddress => email
    )
    assert_not_nil user

    assert_equal @company, user.company
    assert_not_nil user.uuid_
    assert user.active_
    assert_equal [firstname, lastname].join('-').downcase, user.screenname
    assert_equal firstname, user.password_
    assert_equal email, user.emailaddress

    # contact_
    c = Contact.find_by_userid user.id
    assert_equal c, user.contact
    assert_equal user.companyid, c.companyid
    assert_equal user.company.accountid, c.accountid
    assert_equal firstname, c.firstname
    assert_equal lastname, c.lastname
    assert_equal 0, c.prefixid
    assert_equal 0, c.suffixid
    assert_equal 0, c.parentcontactid

    # check "User" and "Power User" roles
    _userrole = Role.find(:first, :conditions => "companyid=#{user.companyid} AND name='User'")
    _powerrole = Role.find(:first, :conditions => "companyid=#{user.companyid} AND name='Power User'")
    assert user.roles.include?(_userrole)
    assert user.roles.include?(_powerrole)

    # group
    g = Group.find_by_classpk(user.id)
    assert_not_nil g
    assert_equal g, user.hive

    assert_equal user.companyid, g.companyid
    assert_equal user.id, g.creatoruserid
    assert_equal Classname.find_by_value(user.liferay_class).id, g.classnameid
    assert_equal user.id, g.classpk
    assert_equal 0, g.parentgroupid
    assert_equal 0, g.livegroupid
    assert_equal 0, g.type_
    assert_equal '/'+user.screenname, g.friendlyurl
    assert g.is_active?

    assert_not_nil g.public_layoutset
    assert_not_nil g.private_layoutset

    g.layoutsets.each do |ls|
      assert_equal user.companyid, ls.companyid
      assert_equal false, ls.logo
      assert_equal 0, ls.logoid
      assert_equal 0, ls.pagecount
    end

    rc = user.resource_code(4)
    assert_not_nil rc

    # resource
    resources = user.resources.select{|r| r.codeid == rc.id}
    assert !resources.empty?
    resource = resources.first
    # counter
#     assert_equal (counter_resource.currentid+100), counter_resource.reload.currentid

    # permissions
    user.class.actions.each do |action|
      p = resource.permissions.select{|_p| _p.actionid==action}.first
      assert_not_nil p
      assert_equal user.companyid, p.companyid
      assert user.permissions.include?(p)
    end
    # counter
#     assert_equal (counter_permission.currentid+100), counter_permission.reload.currentid

    # announcementsdelivery
    ['general','news','test'].each do |type|
      d = Announcement::Delivery.find(:first,
        :conditions => "userid=#{user.id} AND type_='#{type}'")

      assert_equal user.companyid, d.companyid
      assert_equal false, d.email
      assert_equal false, d.sms
      assert_equal true, d.website
    end
  end

  def destroy_user
    firstname = 'Test'
    lastname  = 'User'
    email     = 'test@localhost'
    counter_permission = Counter.find_by_name('com.liferay.portal.model.Permission')
    counter_resource = Counter.find_by_name('com.liferay.portal.model.Resource')

    user = User.create(
      :company   => @company,
      :firstname => 'Test',
      :lastname  => 'User'
    )
    assert_not_nil user

    resources = user.resources
    permissions = user.permissions
    roles = user.roles

    contact = user.contact
    assert_not_nil contact

    group = u.hive
    assert_not_nil group

    layoutsets = group.layoutsets

    ###
    user.destroy
    ###

    assert_raise(ActiveRecord::RecordNotFound) { contact.reload }
    assert_raise(ActiveRecord::RecordNotFound) { group.reload }
    layoutsets.each do |ls|
      assert_raise(ActiveRecord::RecordNotFound) { ls.reload }
    end

    ['general','news','test'].each do |type|
      assert_nil Announcement::Delivery.find(:first,
        :conditions => "userid=#{u.id} AND type_='#{type}'")
    end
  end

#   # organization membership
#   def test_assign_organization_membership
#     user = @users.first
#
#     org_role = Role.find(:first, :conditions => "companyid=#{user.companyid} AND name='Organization Member'")
#     assert_not_nil org_role
#
#     @company.organizations.each do |org|
#       user.assign_organization_membership(org)
#       assert user.organizations.include?(org)
#
#       # can ActiveRecord handle 3-way associations?
#       r = ActiveRecord::Base.connection.execute(
#             "SELECT * from usergrouprole WHERE userid=%i;" % user.id)
#       assert_equal 1, r.result.size
#       res = r.result.first
#       assert_equal user.id, res[0].to_i
#       assert_equal org.group.id, res[1].to_i
#       assert_equal org_role.id, res[2].to_i
#     end
#   end

  def test_gsm
    nr = Kernel.rand(10000000).to_s
    u = @users.first
    u.phones.each(&:destroy)

    u = User.find u.id
    u.gsm = nr

    phone = u.phones.first
    assert_not_nil phone
    assert_equal u.companyid, phone.companyid
    assert_equal u.fullname, phone.username
    assert_equal Classname.find_by_value('com.liferay.portal.model.Contact').id, phone.classnameid
    assert_equal u.contact.id, phone.classpk
    assert_equal nr, phone.number_
    assert_equal ListType.find_by_name('Mobile').id, phone.typeid
    assert phone.is_primary?
  end

  # each user must belong to a company
  def test_company
    companies = Company.all
    @users.each do |x|
      assert_equal Company, x.company.class
      assert companies.include?(x.company)
    end
  end

  # each user must have a contact
  def test_contact
    @users.each do |x|
      assert_not_nil x.contact, x.inspect unless x.is_default?
    end
  end

  def test_fullname
    @users.each do |x|
      assert_not_nil x.fullname unless x.is_default?
    end
  end

  def test_sex
    @users.each do |x|
      assert_not_nil x.sex unless x.is_default?
    end
  end

  # each user can have a personal group (hive)
  def test_hive
    @users.each do |user|
      group = user.hive
      # since Liferay 5.2.3 guest has group
      #if user.is_guest?
      #  assert_nil group
      #else
      #  assert_not_nil group, 'User %i has no "home" group' % user.id
      #end
      next unless group
      # the group must have a proper classnameid
      _class = Classname.find_by_value user.liferay_class
      assert_not_nil _class
      assert_equal _class.id, group.classnameid, "#{user.id}'s personal group is not assigned to #{user.liferay_class}"

      assert_not_nil group.friendlyurl

      # if user is active, hive is active, and vice versa
      if user.is_active?
        assert group.is_active?, "#{user.id}'s personal group is not active"
        # there has to be layoutsets
        assert !group.layoutsets.empty?, "#{user.id}'s personal group does not have layoutsets"

      # ..except that Liferay-5.1 doesn't seem to unactivate the group
      else
        #assert !group.is_active?, "#{user.id}'s personal group is active, while the user is not"

      end
    end
  end

  def test_organizations
    orgs = @users.map{|x| x.orgs}.flatten.uniq
    # Liferay 5.2.3
    assert_equal 11, orgs.size
    orgs.each do |org|
      assert_equal Organization, org.class
    end
  end

  def test_all_groups
    # each group must exist!
    groups = @users.map{|x| x.groups}.flatten.uniq
    # Liferay 5.2.3
    assert_equal 1, groups.size
    groups.each do |group|
      assert_equal Group, group.class
    end
  end

  def test_all_roles
    # each role must exist!
    roles = @users.map{|x| x.roles}.flatten.uniq
    # Liferay 5.2.3
    assert_equal 3, roles.size
    roles.each do |role|
      assert_equal Role, role.class
    end
  end

  def test_all_permissions
    permissions = @users.map{|x| x.permissions}.flatten.uniq
    # Liferay 5.2.3
    assert_equal 0, permissions.size
    permissions.each do |permission|
      assert_equal Permission, permission.class
    end
  end

  def test_all_usergroups
    usergroups = @users.map{|x| x.usergroups}.flatten.uniq
    # Liferay 5.2.3
    assert_equal 0, usergroups.size
    usergroups.each do |usergroup|
      assert_equal Usergroup, permission.class
    end
  end

  def test_path
    @users.each do |u|
      unless u.hive.nil?
        assert_not_nil u.path(:public), u.id if u.hive.public_layoutset
        assert_not_nil u.path(:private), u.id if u.hive.private_layoutset
      end
    end
  end

end
