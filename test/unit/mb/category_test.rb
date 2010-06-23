# encoding: utf-8

require 'test/test_helper'

class MB::CategoryTest < ActiveSupport::TestCase
  fixtures [
    :Company,
    :User_,
    :Group_,
    :MBCategory,
    :MBDiscussion,
    :MBMessage,
    :MBThread,
    :Layout,
    :TagsAsset,
    :portletproperties
  ]

  def setup
    @categories = MB::Category.all
    flunk 'No categories to test' unless @categories.any?
    @categories.delete(MB::Category.find(0))
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
      assert_not_nil x.company, "Category #{x.id} belongs to no company"
    end
  end

  def test_group
    @categories.each do |x|
      assert_not_nil x.group, "Category #{x.id} belongs to no group!"
    end
  end

  def test_user
    @categories.each do |x|
      assert_not_nil x.user, "Category #{x.id} belongs to no user!"
    end
  end

  def test_messages
    @categories.each do |x|
      assert_not_nil x.messages
      x.messages.each do |msg|
        assert_equal x, msg.category
      end
    end
  end

  def test_parent
    @categories.each do |x|
      unless x.parentcategoryid == 0 then
        assert_not_nil x.parent, "Category #{x.id} refers to parent category #{x.parentcategoryid} which does not exist"
      end
    end
  end

  def test_asset
    @categories.each do |x|
      assert_not_nil x.asset
    end
  end

  def test_subcategories
    @categories.each do |x|
      next if x.parentcategoryid==0
      assert_not_nil x.subcategories
    end
  end

  def test_threads
    @categories.each do |x|
      assert_not_nil x.threads
      x.threads.each do |thrd|
        assert_equal x, thrd.category
      end
    end
  end

  def test_path
    @categories.each do |x|
      unless x.group
        STDERR.puts 'WARN: message_boards category %i does not belong to a group' % x.id
        next
      end
      if x.group.layouts_include?('message_boards')
        assert_not_nil x.path
      else
        assert_nil x.path
      end
    end
  end

end
