require 'test_helper'

class Web::LayoutTest < ActiveSupport::TestCase
  fixtures [
    :layout, :layoutset, :portlet, :portletpreferences, :portlet_names, :resourcecode
  ]

  def setup
    @layouts = Web::Layout.find :all
    assert !@layouts.empty?
  end

  def test_create
    group = Group.first

    # public
    layoutset = group.public_layoutset
    layouts = layoutset.layouts.size

    ids = group.public_layouts.collect(&:layoutid)

    layout = Web::Layout.create(
      :group => group,
      :privatelayout => false
    )
    assert_not_nil layout

    assert_equal group, layout.group
    assert_equal group.companyid, layout.companyid
    assert_equal layoutset, layout.layoutset
    assert_not_nil layout.layoutid

    assert !ids.include?(layout.layoutid)

    assert_not_nil layout.friendlyurl
    assert_equal 'portlet', layout.type_
    assert_not_nil layout.typesettings
    assert_not_nil layout.title
    assert_not_nil layout.description
    assert_not_nil layout.hidden_

    layoutset.reload
    assert_equal layouts+1, layoutset.pagecount

    rc = layout.resource_code(2)
    assert_not_nil rc
    assert_not_nil Resource.find(:first, :conditions => "codeid=#{rc.id} AND primkey='#{group.id}'")

    rc = layout.resource_code(4)
    assert_not_nil rc
    resource = Resource.find(:first, :conditions => "codeid=#{rc.id} AND primkey='#{layout.id}'")
    assert_not_nil resource


    group.reload

    layout.class.actions.each do |actionid|
      p = Permission.find(:first,
        :conditions => "companyid=#{layout.companyid} AND actionid='#{actionid}' AND resourceid=#{resource.id}")
      assert_not_nil p

      assert group.permissions.include?(p)
    end
  end

  # each layout must belong to a company
  def test_company
    @layouts.each do |x|
      assert !x.company.nil?, "#{x} has no company"
    end
  end

  # each layout must belong to a group
  def test_group
    @layouts.each do |x|
      assert !x.group.nil?, "#{x} has no group"
    end
  end

  def test_rigidity
    @layouts.each do |x|
      assert !x.is_public?.nil?
    end

    # each group must exist!
    groups = @layouts.map{|x| x.group}.uniq
    groups.each do |group|
      assert !group.nil?, "Reference to non-existing group  #{group.inspect}"
    end
  end

  # each layout must have layoutid within the group,
  # there must be no duplicate layoutids
  def test_layoutid
    @layouts.each do |x|
      assert !x.layoutid.nil?, "#{x} has no local layout number"
    end

      groupids = @layouts.map{|x| x.groupid}.uniq
      groupids.each do |gid|
        # find all group's layoutids
        pub = Web::Layout.find(:all, :conditions => "groupid=#{gid} AND privatelayout=false").map{|x| x.layoutid}
        priv = Web::Layout.find(:all, :conditions => "groupid=#{gid} AND privatelayout=true").map{|x| x.layoutid}

        # they must have no overlapping ids
        assert pub.uniq == pub, "Group #{gid} has duplicate public layoutids"
        assert priv.uniq == priv, "Group #{gid} has duplicate private layoutids"
      end
  end

  # each layout must have a friendlyurl
  def test_friendlyurl
    @layouts.each do |x|
      assert !x.friendlyurl.nil?, "#{x} has no friendlyurl"
    end
  end

  # each layout must have a name
  def test_name
    @layouts.each do |x|
      assert !x.name.nil?, "#{x} has no name"
    end
  end

  # each layout must have a typesettings, and the defined portlets exist
  def test_portlets
    @layouts.each do |x|
      assert !x.typesettings.nil?, "#{x} has no typesettings"

      # check portlets
      x.portletids.each do |id|
        next if id[/INSTANCE/]
        assert Web::Portlet.find_by_portletid(id), "Layout #{x.id} defines portlet #{id} but it is not found in the portlet table"
      end

      # check instances
      x.instances.each do |portlet|
        portletid = portlet.portletid
        next unless portletid[/INSTANCE/]
        assert Web::PortletPreferences.find_by_portletid(), "#{x.id} defines portlet instance #{portletid} but it is not found in portletpreferences"
      end
    end
  end

end