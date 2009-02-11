require 'test_helper'

class Web::PortletPreferencesTest < ActiveSupport::TestCase
  fixtures :portletpreferences, :resource_, :portlet, :portletitem

  def setup
    @prefs = Web::PortletPreferences.all
  end

#   # each preference must belong to an owner
#   def test_owner
#     @prefs.each do |x|
#       unless x.ownerid == 0
#         assert_not_nil x.owner, "#{x.id} belongs to no owner"
#       end
#     end
#   end

  # each preference must define ownertype
  def test_ownertype
    @prefs.each do |x|
      assert_not_nil x.ownertype, "#{x.id} defines no ownertype"
    end
  end

  # each preference must belong to a layout
  def test_layout
    @prefs.each do |x|
      unless x.plid == 0
        assert_not_nil x.layout, "#{x.id} refers to non-existing layout #{x.plid}"
      end
    end
  end

  # each preference must have a portletid
  def test_portletid
    @prefs.each do |x|
      assert_not_nil x.portletid, "#{x.id} has no portletid"
    end
  end

  # there has to be a resource for each portletpreference
  def test_resource
    @prefs.each do |x|
      unless x.plid == 0
        assert_not_nil x.resource(x.plid), "No resource with primkey #{x.primkey}"
      end
    end
  end

end
