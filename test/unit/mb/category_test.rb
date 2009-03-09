require 'test_helper'

class MB::CategoryTest < ActiveSupport::TestCase
  fixtures [
    :mbcategory,
    :mbdiscussion,
    :mbmessage,
    :mbthread,
    :group_,
    :layout
  ]
  if defined? Caterpillar
    fixtures << :portletproperties
  end


  def setup
    @categories = MB::Category.all
    @rootcategory = MB::Category.find 0
    @categories.delete @rootcategory
  end

  def test_create
    # find first user that has a personal group
    user = nil
    User.all.each do |user|
      break if user.hive
    end
    group = user.hive
    assert_not_nil group

    category = MB::Category.create(
      :name => 'Test',
      :group => group,
      :user => user
    )
    assert_not_nil category

    assert_equal group, category.group
    assert_equal user, category.user
    assert_equal user.fullname, category.username
    assert_equal 0, category.parentcategoryid

    # ResourceCode with scope 1 => Resource for Company
    # ResourceCode with scope 2 => Resource for this Group and Guest's Group
    # ResourceCode with scope 4 => Resource for self

    rc = category.resource_code(1)
    assert_not_nil rc
    assert_not_nil Resource.find(:first,
      :conditions => "codeid=#{rc.id} AND primkey='#{group.companyid}'")

    rc = category.resource_code(2)
    assert_not_nil rc
    assert_not_nil Resource.find(:first,
      :conditions => "codeid=#{rc.id} AND primkey='#{group.id}'")

    rc = category.resource_code(4)
    assert_not_nil rc
    resource = Resource.find(:first,
      :conditions => "codeid=#{rc.id} AND primkey='#{category.id}'")
    assert_not_nil resource

    category.class.actions.each do |actionid|
      p = Permission.find(:first,
        :conditions => "companyid=#{category.companyid} AND actionid='#{actionid}' AND resourceid=#{resource.id}")
      assert_not_nil p
      assert user.permissions.include?(p)
    end
  end

  # each article must belong to a company
  def test_company
    @categories.each do |x|
      assert_not_nil x.company, "#{x.id} belongs to no company"
    end
  end

  def test_group
    @categories.each do |x|
      assert_not_nil x.group, "#{x.id} belongs to no group!"
    end
  end

  def test_user
    @categories.each do |x|
      assert_not_nil x.user, "#{x.id} belongs to no user!"
    end
  end

  def test_parent
    @categories.each do |x|
      unless x.parentcategoryid == 0 then
        assert_not_nil x.parent, "#{x.id} refers to parent category #{x.parentcategoryid} which does not exist"
      end
    end
  end

  def test_root
    assert_equal 0, @rootcategory.companyid
    assert_equal 0, @rootcategory.groupid
    assert_equal 0, @rootcategory.userid
    assert_equal 0, @rootcategory.parentcategoryid
  end

  def test_path
    @categories.each do |x|
      if x.group.layouts_include?('message_boards')
        assert_not_nil x.path
      else
        assert_nil x.path
      end
    end
  end

end
