require 'test_helper'

# Beware, these tests are slow due to the amount of portletpreferences

class Web::PortletPropertiesTest < ActiveSupport::TestCase
  fixtures [
    :Company,
#     :User_,
#     :Group_,
    :Portlet,
    :PortletPreferences,
    :portletproperties,
    :Layout
  ]

  def setup
    @props = Web::PortletProperties.all
    flunk 'No portlet properties -- remember Caterpillar migrations!' unless @props.any?
  end

  def test_portlet
    @props.each do |pp|
      assert_not_nil pp.portlet
      assert_equal Web::Portlet, pp.portlet.class
    end
  end

  def test_find_by_name
    @props.each do |pp|
      portlet_by_name = Web::Portlet.find_by_name(pp.name)
      assert_not_nil portlet_by_name

      assert_equal pp, portlet_by_name.properties

      portlet = Web::Portlet.find_by_portletid(pp.portletid)
      next unless portlet

      assert_equal portlet, portlet_by_name
    end
  end

end
