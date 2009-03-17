require 'test_helper'

class Web::LayoutTest < ActiveSupport::TestCase
  fixtures [
    :layout, :layoutset, :portlet, :portletpreferences, :resourcecode, :portletproperties
  ]

  def setup
    @layouts = Web::Layout.all
    assert !@layouts.empty?

    group = Company.first.guest_group
    @clean_layout = group.public_layouts.first #select{|l| l.friendlyurl=='/home'}.first

    flunk ('No guest layouts in group %i' % group.id) unless @clean_layout
    @clean_layout.settings = Web::Typesettings.new # clean it up
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


      # group members can ADD_DISCUSSION and VIEW
      if (actionid=='ADD_DISCUSSION' or actionid=='VIEW')
        assert group.permissions.include?(p)
      end

      # guest is permitted to VIEW if the layout is public.
      if layout.is_public? and actionid=='VIEW'
        assert group.company.guest.permissions.include?(p)
      end

    end

#     # the layout management portlet (new in 5.2.x?)
#     assert_not_nil Web::PortletPreferences.find(:first,
#       :conditions => "plid=#{layout.plid} AND portletid='88'")
  end

  # tests .<<()
  def test_append_to_self
    layout = @clean_layout
    portlet_name = 'tagged_content'

    layout.settings = Web::Typesettings.new

    ### instantiate a rails portlet as Web::Portlet
    ### find a Liferay portlet (hello world)
    [
      Web::Portlet.first,
      Web::Portlet.find_by_name('hello_world')
    ].each do |portlet|
      flunk 'No portlet to test on' unless portlet
      assert_not_nil portlet.preferences
      #puts portlet.inspect
#             puts portlet.resource.inspect
      
      # TODO: test instantiate & no instantiated portlets, already instantiated, test that preferences.id matches

      layout.<<( portlet, {:location => { :column => 1 }})
      #puts layout.inspect
      
      ### OK. Let the testing begin
      
      portlet.reload
      group = layout.group
      assert_equal group, portlet.preferences.layout.group
      #assert_equal portlet.companyid, group.companyid

      # COPY portletpreferences (portletpreferencesid, ownerid, ownertype, plid, portletid, preferences) FROM stdin;
      # +10267	0	3	10264	guidance_communities_INSTANCE_Hs9t	<portlet-preferences />

      preferences = portlet.preferences
      unless portlet.instanceable?
        assert_not_nil preferences
        assert_equal ({1=>[portlet.portletid]}), layout.settings.portlets

      else
        assert_not_nil preferences
#         puts preferences.inspect
        assert preferences.portletid[/INSTANCE/]
        assert_equal layout.plid, preferences.plid

        assert_equal ({1=>[preferences.portletid]}), layout.settings.portlets
      end

      # COPY resourcecode (codeid, companyid, name, scope) FROM stdin;
      # +111	10178	guidance_communities	4
      # +112	10178	guidance_communities	1
      # +113	10178	guidance_communities	2

      # COPY resource_ (resourceid, codeid, primkey) FROM stdin;
      # +137	112	10178
      # +138	113	10198
      # +139	111	10264_LAYOUT_guidance_communities_INSTANCE_Hs9t

      [1,2,4].each do |scope|
        rc = preferences.resource_code(scope)
        assert_not_nil rc
        assert_equal layout.companyid, rc.companyid
        # rc.name does not depend on instanceability
        assert_equal portlet.portletid, rc.name

        rc = preferences.resource_code(scope)
        assert_not_nil rc
        r = preferences.get_resource(:scope => scope)
        assert_not_nil r
        assert_equal r.codeid, rc.id
        case scope
        when 1
          assert_equal layout.companyid.to_s, r.primkey
        when 2
          assert_equal group.id.to_s, r.primkey
        when 4
          assert_equal preferences.primkey, r.primkey
        end
      end

      # COPY permission_ (permissionid, companyid, actionid, resourceid) FROM stdin;
      # +135	10178	VIEW	139
      # +136	10178	CONFIGURATION	139

      # COPY groups_permissions (groupid, permissionid) FROM stdin;
      # +10198	135

      # COPY users_permissions (userid, permissionid) FROM stdin;
      # +10180	135

      resource = preferences.get_resource(:scope => 4)
      guest = group.company.guest
      preferences.class.actions.each do |actionid|
        p = Permission.find(:first,
          :conditions => "companyid=#{group.companyid} AND actionid='#{actionid}' AND resourceid=#{resource.id}")
        assert_not_nil p
        if actionid=='VIEW'
          assert group.permissions.include?(p)

          if layout.is_public?
            assert guest.permissions.include?(p)
          end
        end
      end
    end
  end

  def test_append_portlets
    layout = @clean_layout

    login_portlet = Web::Portlet.find_by_name 'login'
    assert_not_nil login_portlet
    login_portlet.instanceable=false

    hw_portlet = Web::Portlet.find_by_name 'hello_world'
    assert_not_nil hw_portlet
    hw_portlet.instanceable=true

    layout.<<( login_portlet, {:location => { :column => 1 }})
    layout.<<( hw_portlet, {:location => { :column => 2 }})

    layout.save

    assert_equal 2, layout.portlets.size

    portletids = layout.portlets.collect(&:portletid)

    assert portletids.include?(login_portlet.portletid)
    assert (portletids && [/#{hw_portlet.portletid}_INSTANCE/]).any?
  end

  def test_columns
    layout = @clean_layout

    layout.columns=1
    assert_equal '1_column', layout.settings.template_id

    layout.columns=2
    assert_equal '2_columns_ii', layout.settings.template_id
  end

  def test_name_string
    layout = @clean_layout

    # set the name.
    #
    # as the method 'name' returns the name in XML, name_string is a string representation.
    name = 'front page'
    layout.name_string = name
    assert_equal name, layout.name_string
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

      x.portlets.each do |p|
        if p.is_a?(Web::PortletPreferences)
          assert_equal x, p.layout, 'Layout has a portlet(preferences) (%i) that does not belong there' % p.id
          if p.portlet
            assert p.portlet.instanceable?
          end

        else # not instantiated
          assert_equal x, p.preferences.layout
          assert !p.instanceable?
        end
      end

      # check portlets
      x.portletids.each do |id|
        next if id[/INSTANCE/]
        unless Web::Portlet.find_by_portletid(id)
          STDERR.puts "WARN: Layout #{x.id} defines portlet #{id} but it is not found in the portlet table"
        end
      end

      # check instances
      x.instances.each do |portlet|
        portletid = portlet.portletid
        next unless portletid[/INSTANCE/]
        assert Web::PortletPreferences.find_by_portletid(portletid), "#{x.id} defines portlet instance #{portletid} but it is not found in portletpreferences"
      end
    end
  end

end