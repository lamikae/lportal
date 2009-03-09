require 'test_helper'

class Web::PortletPreferencesTest < ActiveSupport::TestCase
  fixtures :portletpreferences, :portlet, :layout
  if defined? Caterpillar
    fixtures << :portlet_names
  end

  def setup
    @prefs = Web::PortletPreferences.all
    @portlet = Web::Portlet.first
    flunk 'no portlet to test on' unless @portlet
    @layout = Web::Layout.first
    flunk 'no layout to test on' unless @layout
  end

#   def test_create
#     portlet = Web::Portlet.find_by_name('login')
#     prefs = Web::PortletPreferences.create(
#       :portlet => portlet
#     )
#     assert_not_nil prefs
#     assert_equal portlet.portletid, prefs.portletid
#   end

  def test_primkey_noninstanceable
    @portlet.instanceable=false

    preferences = @portlet.preferences
    assert_not_nil preferences

    assert_equal @portlet.portletid, preferences.portletid # not instantiated
    preferences.layout = @layout
    assert_equal '%i_LAYOUT_%s' % [@layout.plid, preferences.portletid], preferences.primkey
  end

  def test_primkey_instanceable
    @portlet.instanceable=true

    preferences = @portlet.preferences
    assert_not_nil preferences

    assert_not_nil preferences.portletid[/#{@portlet.portletid}_INSTANCE/] # instantiated
    preferences.layout = @layout
    assert_equal '%i_LAYOUT_%s' % [@layout.plid, preferences.portletid], preferences.primkey
  end

  def test_resources
    @portlet.instanceable=false

    preferences = @portlet.preferences
    assert_not_nil preferences
    preferences.layout = @layout

    assert_not_nil preferences.get_resource(:scope => 1)

    assert_not_nil preferences.scope2_primkey
    assert_not_nil preferences.scope4_primkey

    resource = preferences.get_resource(:scope => 2)
    assert_not_nil resource
    assert_equal @layout.groupid.to_s, resource.primkey

    resource = preferences.get_resource(:scope => 4)
    assert_equal preferences.primkey, resource.primkey
  end

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

end
