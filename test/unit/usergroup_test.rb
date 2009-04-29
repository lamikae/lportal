require 'test_helper'

class UsergroupTest < ActiveSupport::TestCase
  fixtures :Company, :Group_, :UserGroup

  def setup
    @usergroups = Usergroup.all
  end

  # each usergroup must belong to a company
  def test_company
    @usergroups.each do |x|
      assert_not_nil x.company, "#{x.id} belongs to no company"
    end
  end

  # each usergroup must belong to a company
  def test_parent
    @usergroups.each do |x|
      unless x.parentusergroupid == 0
        assert_not_nil x.parent, "#{x.id} has no parent"
      end
    end
  end

  def test_groups
    @usergroups.each do |x|
      x.groups.each do |group|
        assert_not_nil group, "#{x.id} has_and_belongs_to an unknown group"
      end
    end
  end

end
