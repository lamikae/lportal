require 'test_helper'

class Web::PortletTest < ActiveSupport::TestCase
  fixtures [
    :portletpreferences, :portlet, :layout, :portletproperties
  ]

  def setup
    @portlets = Web::Portlet.all
    @portlet = Web::Portlet.first
    flunk 'no portlet to test on' unless @portlet
    @layout = Web::Layout.first
    flunk 'no layout to test on' unless @layout
  end

  def test_noninstanceable
    @portlet.instanceable=false

    preferences = @portlet.preferences
    assert_not_nil preferences
    assert_equal @portlet.portletid, preferences.portletid # not instantiated!
  end

  def test_preferences
    @portlets.each do |x|
      assert_not_nil x.preferences, 'Portlet %i has no preferences' % x.id
    end
  end

  def test_properties
    @portlets.each do |portlet|
      pp = portlet.properties
      unless pp
        STDERR.puts 'NOTICE: portlet ”%s” is not parsed from XML. Old data perhaps?' % portlet.portletid
        next
      end

      assert_not_nil pp.portletid
      assert_not_nil pp.name
      assert_not_nil pp.title
      assert_not_nil portlet.properties.instanceable
      assert_equal portlet.properties.instanceable, portlet.instanceable?

      assert_not_nil Web::Portlet.find_by_portletid(pp.portletid)
    end
  end

  def test_find_by_name
    Web::PortletProperties.all.each do |pp|
      portlet_by_name = Web::Portlet.find_by_name(pp.name)
      assert_not_nil portlet_by_name

      assert_equal pp, portlet_by_name.properties

      portlet = Web::Portlet.find_by_portletid(pp.portletid)
      next unless portlet

      assert_equal portlet, portlet_by_name
    end
  end

  def test_title
    @portlets.each do |portlet|
      assert_not_nil portlet.title
      if portlet.properties
        assert_not_equal '', portlet.title
      end
    end
  end

  # only instanceable portlets have resources
  def test_instanceable
    @portlet.instanceable=true

    preferences = @portlet.preferences
    assert_not_nil preferences
    assert_not_nil preferences.portletid[/#{@portlet.portletid}_INSTANCE/] # instantiated!
  end

  # each portlet must belong to a company
  def test_company
    @portlets.each do |x|
      assert_not_nil x.company
    end
  end

end
