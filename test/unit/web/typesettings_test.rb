require 'test_helper'

class TypesettingsTest < ActiveSupport::TestCase
  fixtures [
    :layout,
#     :portlet, :portletpreferences
  ]

  def setup
    # test caterpillar migrations
    p = Web::PortletName.first
    flunk 'Please run Caterpillar migrations' unless p

    @mb = Web::PortletName.find_by_name 'message_boards'
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

  def test_include
    ts = Web::Typesettings.new.message_boards(:column => 2)
    assert ts.include?(Web::PortletName.find_by_name('message_boards'))
    assert !ts.include?(Web::PortletName.find_by_name('translator'))
    assert ts.include?('message_boards')
    assert !ts.include?('translator')
  end

  def test_read
    ts = Web::Typesettings.new.message_boards(:column => 2).to_s
    _ts = Web::Typesettings.new(ts)
    assert_equal ts, _ts.to_s
  end

  def test_layouts
puts
    Web::Layout.all.each do |layout|
      ts = layout.typesettings
      # compare string lengths
puts ts.inspect
puts layout.contents.to_s.inspect
      assert_equal ts.size, layout.contents.to_s.size
puts '...'
    end
  end

end
