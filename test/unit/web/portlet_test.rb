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

    # TODO: DRY up, the same creation code is in asset test.
    unless Web::Portlet.find_by_name('asset_publisher')
      Company.all.each do |c|
        Web::Portlet.create(
          :companyid => c.id,
          :portletid => '9998'
        )
        Web::PortletProperties.create(
          :portletid => 9998,
          :name => 'asset_publisher',
          :title => ''
        )
      end
    end
    unless Web::Portlet.find_by_name('tagged_content')
      Company.all.each do |c|
        Web::Portlet.create(
          :companyid => c.id,
          :portletid => '9999'
        )
        Web::PortletProperties.create(
          :portletid => 9999,
          :name => 'tagged_content',
          :title => ''
        )
      end
    end
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
        #RAILS_DEFAULT_LOGGER.warn 'NOTICE: portlet ”%s” is not parsed from XML. Old data perhaps?' % portlet.portletid
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
    @portlets.each do |p|
      next unless p.name
      portlet_by_name = Web::Portlet.find_by_name(p.name)
      assert_not_nil portlet_by_name
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

  def test_asset_publisher_path
    group = Group.first
    flunk 'No group to test on' unless group

    layout = Web::Layout.first
    flunk 'No layout to test on' unless layout

    asset = Tag::Asset.first
    flunk 'No asset to test on' unless asset

    [5100, 5200].each do |build|
      Lportal::Schema.buildnumber = build

      name = (
        if build==5100
          'tagged_content'
        else
          'asset_publisher'
        end
      )

      portlet = Web::Portlet.find_by_name(name)
      assert_not_nil portlet, 'Could not find portlet %s' % name
      layout.<< portlet

      path = portlet.preferences.path(:asset => asset)
      assert_not_nil path
      #assert_not_nil path[/#{portlet.portletid}/]
    end
  end

end
