# encoding: utf-8

require 'test/test_helper'

class TypesettingsTest < ActiveSupport::TestCase
  fixtures [
    :Layout,
    :Portlet, :PortletPreferences, :portletproperties
  ]

  def setup
    # test caterpillar migrations
    p = Web::PortletProperties.first
    flunk 'Please run Caterpillar migrations' unless p

    @mb = Web::PortletProperties.find_by_name 'message_boards'
    assert_not_nil @mb
  end

  def test_empty
    assert_equal "layout-template-id=2_columns_ii\n", Web::Typesettings.new.to_s
    assert_equal "layout-template-id=1_column\n", Web::Typesettings.new(:columns => 1).to_s
  end

  def test_message_boards
    typesettings = "layout-template-id=2_columns_ii\ncolumn-2=%i," % @mb.portletid
    assert_equal typesettings, Web::Typesettings.new.message_boards(:column => 2).to_s
  end

  def test_include_noninstantiated
    flunk mysql_bug if defined?(mysql_bug)

    ts = Web::Typesettings.new.message_boards(:column => 2)
    assert ts.include?(Web::Portlet.find_by_name('message_boards'))
    assert !ts.include?(Web::Portlet.find_by_name('translator'))
    assert ts.include?(Web::PortletProperties.find_by_name('message_boards'))
    assert !ts.include?(Web::PortletProperties.find_by_name('translator'))
    assert ts.include?('message_boards')
    assert !ts.include?('translator')
  end

#   def test_include_instantiated
#     portlet = Web::Portlet.first
    #portlet.instanceable = true
#     ts = Web::Typesettings.new.message_boards(:column => 2)
#     assert ts.include?(Web::PortletProperties.find_by_name('message_boards'))
#     assert !ts.include?(Web::PortletProperties.find_by_name('translator'))
#     assert ts.include?('message_boards')
#     assert !ts.include?('translator')
#   end

  def test_read
    ts = Web::Typesettings.new.message_boards(:column => 2).to_s
    _ts = Web::Typesettings.new(ts)
    assert_equal ts, _ts.to_s
  end

  def test_layouts
    flunk 'this test is incomplete'
    #STDERR.puts
    Web::Layout.all.each do |layout|
      ts = layout.typesettings
      # compare string lengths
#STDERR.puts ts.inspect
#STDERR.puts layout.settings.to_s.inspect
      assert_equal ts.size, layout.settings.to_s.size
#STDERR.puts '...'
    end
  end

end
