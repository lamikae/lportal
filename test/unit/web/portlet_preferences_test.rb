require 'test_helper'

# Beware, these tests are slow due to the amount of portletpreferences

class Web::PortletPreferencesTest < ActiveSupport::TestCase
  fixtures [
    :Company,
#     :User_,
#     :Group_,
    :Portlet,
    :PortletPreferences,
    :PortletProperties,
    :Layout
  ]

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


#   def test_debug
#   ### autom. luonti
# # user = User.find 13904
# # user = User.find 10201
# group = Group.find 10196
# 
# 
# # Teemat
# # ls = group.public_layoutset
# # puts ls.themeid
# # # ls.themeid = 'classicneuvonta_WAR_classicneuvontatheme'
# # # ls.save
# #
# # ly = group.public_layouts
# # puts ly.inspect
# # # puts ly.collect(&:portlets).inspect
# # exit 0
# # create a new public layout for this group
# # layout = Web::Layout.create(
# #   :group => group,
# #   :privatelayout => false,
# #   :name => 'Keskustelut'
# # )
# 
# 
# # COPY layout (plid, groupid, companyid, privatelayout, layoutid, parentlayoutid, name, title, description, type_, typesettings, hidden_, friendlyurl, iconimage, iconimageid, themeid, colorschemeid, wapthemeid, wapcolorschemeid, css, priority, dlfolderid) FROM stdin;
# # +10264	10198	10178	f	3	0	<?xml version='1.0' encoding='UTF-8'?><root available-locales="en_US" default-locale="en_US"><name language-id="en_US">Yhteisöt</name></root>	<root />		portlet	layout-template-id=1_column\ncolumn-1=guidance_communities_INSTANCE_Hs9t	f	/yhteisot	f	0						2	0
# 
# # layout = Web::Layout.find 8400003
# # layout = Web::Layout.find 8400002
# # layout = Web::Layout.find 8400001
# # _l = Web::Layout.find 25871
# # layout = Web::Layout.find 25907
# layout = Web::Layout.find 10199
# assert_not_nil layout
# 
# #   layout.portlets =
# # _ts = layout.typesettings
# 
# puts layout.inspect
# 
# # puts layout.settings.inspect
# # puts layout.portlets.inspect
# # puts layout.portlets.first.inspect
# # exit 0
# 
# puts
# 
# 
# ### instantiate a rails portlet as Web::Portlet
# portlet = Web::Portlet.find_caterpillar_portlet :guidance_communities
# assert_not_nil portlet
# 
# ### find a Liferay portlet (hello world) but do not instantiate
# # portlet = Web::Portlet.create(
# #   :portletid => '47',
# #   :instantiate => false
# # )
# 
# portlet.companyid = group.companyid
# portlet.group = group
# puts portlet.inspect
# 
# ############################
# 
# puts
# 
# # COPY portletpreferences (portletpreferencesid, ownerid, ownertype, plid, portletid, preferences) FROM stdin;
# # +10267	0	3	10264	guidance_communities_INSTANCE_Hs9t	<portlet-preferences />
# 
# ### instance preferences
# prefs = portlet.preferences()
# assert_not_nil prefs
# assert prefs.portletid[/INSTANCE/]
# 
# # prefs = Web::PortletPreferences.create(:portletid => '47')
# # define the layout
# prefs.plid = layout.plid
# 
# prefs.save
# puts prefs.inspect
# ############################
# 
# puts
# 
# ### insert PortletPreferences into Typesettings
# ts = layout.settings
# assert_not_nil ts
# ts.columns = 1
# #<Web::Typesettings:0x7fdcc57985e8 @template_id="1_column", @portlets={}>
# 
# ts.portlets = {1 => [prefs]}
# puts ts.inspect
# puts ts.to_s
# layout.settings = ts
# layout.save
# # puts layout.inspect
# ############################
# 
# puts
# 
# 
# # COPY resourcecode (codeid, companyid, name, scope) FROM stdin;
# # +111	10178	guidance_communities	4
# # +112	10178	guidance_communities	1
# # +113	10178	guidance_communities	2
# 
# # COPY resource_ (resourceid, codeid, primkey) FROM stdin;
# # +137	112	10178
# # +138	113	10198
# # +139	111	10264_LAYOUT_guidance_communities_INSTANCE_Hs9t
# 
# [1,2,4].each do |scope|
#   rc = portlet.resource_code(scope)
#   assert_not_nil rc
#   assert_equal group.companyid, rc.companyid
#   assert_equal portlet.name, rc.name
# 
#   r = portlet.find_resource(:scope => scope)
#   assert_not_nil r
#   assert_equal r.codeid, rc.id
#   case scope
#   when 1
#     assert_equal group.companyid, r.primkey
#   when 2
#     assert_equal group.id, r.primkey
#   when 4
#     assert_equal prefs.primkey, r.primkey
#   end
# end
# 
# 
# # COPY permission_ (permissionid, companyid, actionid, resourceid) FROM stdin;
# # +135	10178	VIEW	139
# # +136	10178	CONFIGURATION	139
# 
# # COPY groups_permissions (groupid, permissionid) FROM stdin;
# # +10198	135
# 
# # COPY users_permissions (userid, permissionid) FROM stdin;
# # +10180	135
# 
# # preferences.save?
# 
# resource = portlet.find_resource(:scope => 4)
# guest = group.company.guest
# portlet.class.actions.each do |actionid|
#   p = Permission.get(
#     :companyid  => group.companyid,
#     :actionid   => actionid,
#     :resourceid => resource.id
#   )
#   assert_not_nil p
#   #puts p.inspect
#   if actionid=='VIEW'
#     group.permissions << p
#     group.reload
#     assert group.permissions.include?(p)
# 
#     guest.permissions << p
#     guest.reload
#     assert guest.permissions.include?(p)
#   end
# end
# 
# 
# 
# 
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

    rc = preferences.resource_code()
    assert_equal @portlet.portletid, rc.name

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
      assert_not_nil x.ownertype, "PortletPreferences #{x.id} defines no ownertype"
    end
  end

  # each preference must belong to a layout
  def test_layout
    @prefs.each do |x|
      # quite a many portletpreferences have no layouts. perhaps they are deleted from the page?
      if x.plid == 0
        assert_nil x.layout
      else
        assert_not_nil x.layout, "PortletPreferences #{x.id} belongs to non-existing layout #{x.plid}"
      end
    end
  end

  def test_portletid
    @prefs.each do |x|
      assert_not_nil x.portletid
      assert_not_equal '', x.portletid
      next unless x.portlet
      if x.portlet.instanceable?
        assert_not_nil x.portletid[/INSTANCE/]
      else
        assert_nil x.portletid[/INSTANCE/]
      end
    end
  end

#   # Liferay leaves portletpreferences in the database while may portletids change due to upgrades.
#   def test_portlet
#     @prefs.each do |x|
#       unless x.portlet
#         STDERR.puts 'NOTICE: Portlet not found for PortletPreferences %i' % x.id
#       end
#     end
#   end

  def test_title
    @prefs.each do |x|
      if x.properties
        assert_equal x.properties.title, x.title
        if x.portlet
          assert_equal x.title, x.portlet.title
        end
      end
    end
  end

  def test_name
    @prefs.each do |x|
      if x.properties
        assert_equal x.properties.name, x.name
        if x.portlet
          assert_equal x.name, x.portlet.name
        end
      end
    end
  end

  def test_portlet_id
    @prefs.each do |x|
      next unless x.portletid or x.portletid.empty?
      assert_not_nil x.portlet_id
      assert_nil x.portlet_id[/INSTANCE/]
      next unless x.portlet # these cannot be tested without knowing the portlet
      if x.portlet.instanceable?
        assert_not_nil x.instance_id
      else
        assert_nil x.instance_id
      end
      assert_equal x.portlet.portletid, x.portlet_id
    end
  end

  def test_tos
    @prefs.each do |x|
      assert_not_nil x.preferences
      assert_equal String, x.preferences.class
      xml = x.to_xml
      assert_not_nil xml
      assert_equal REXML::Document, xml.class
      arr = x.to_a
      assert_not_nil arr
      assert_equal Array, arr.class
    end
  end

  def test_companyid
    @prefs.each do |x|
      if x.layout
        assert_equal x.layout.companyid, x.companyid
      else
        assert_nil x.companyid
        c = Company.first
        x.companyid=c.id
        assert_equal c.id, x.companyid
      end
    end
  end

end
