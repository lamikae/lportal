module Web
  # Page layouts. These are individual layouts for items in the navigation bar.
  # Layouts have portlets, these are modeled by parsing (by regexp) the typesettings xml. Layouts belong to a certain LayoutSet.
  class Layout < ActiveRecord::Base

    acts_as_resourceful

    # FIXME: does not work properly. even if the layoutid is available, this causes self.errors
    #validates_uniqueness_of :layoutid, :scope => [:groupid, :privatelayout]

    # Actions for Permissions.
    def self.actions
      %w{
      ADD_DISCUSSION
      UPDATE
      VIEW
      }
    end

    # Creates a new Layout.
    #
    # This process is engineered by creating a new layout with Liferay's (v. 5.1.1) tools and
    # inspecting the database dump diffs.
    #
    # Mandatory parameters:
    #  - groupid
    #  - privatelayout (true or false)
    #
    # Optional extra parameters:
    #  - locale
    def initialize(params)
      logger.debug params.inspect
      raise 'No groupid given' unless (params[:groupid] or params[:group])
      raise 'No privatelayout given' if params[:privatelayout].nil?
      _name = params.delete(:name) || 'New layout'
      _locale = params[:locale] || 'en_US'

      super(params)

      # COPY layout (plid, groupid, companyid, privatelayout, layoutid, parentlayoutid, name, title, description, type_, typesettings, hidden_, friendlyurl, iconimage, iconimageid, themeid, colorschemeid, wapthemeid, wapcolorschemeid, css, priority, dlfolderid) FROM stdin;
      # +10301	10166	10109	f	1	0	<?xml version='1.0' encoding='UTF-8'?><root available-locales="en_US" default-locale="en_US"><name language-id="en_US">frontpage</name></root>	<root />		portlet	layout-template-id=2_columns_ii\n	f	/1	f	0						0	0

      self.companyid = self.group.companyid

      name = "<?xml version='1.0' encoding='UTF-8'?>"
      name += '<root available-locales="%s" default-locale="%s">' % [_locale, _locale]
      name += '<name language-id="%s">' % _locale
      name += _name
      name += '</name></root>'
      self.name = name
      self.save

      # perhaps layoutid could be sequenced.
      layouts = (self.is_public? ? self.group.public_layouts : self.group.private_layouts)
      _ids = (layouts.any? ? layouts.collect(&:layoutid) : nil)
      self.layoutid = (_ids.nil? ? 1 : _ids.sort.max+1)
      self.save

      # increment pagecount
      _set = self.layoutset
      if _set
        _set.pagecount += 1
        _set.save
      end

      self.friendlyurl    ||= '/'+self.layoutid.to_s
      self.type_          ||= 'portlet'
      self.typesettings   ||= Web::Typesettings.new.to_s # 'bout to change
      self.title          ||= '<root />'
      self.description    ||= ''
      self.parentlayoutid ||= 0
      self.priority       ||= 0
      self.dlfolderid     ||= 0
      self.iconimageid    ||= 0
      self.iconimage = false if self.iconimage.nil?
      self.hidden_ = false if self.hidden_.nil?

      self.save

      #####
      # Group 10166 is a private group of User 10164.
      # 10129 is the Company's admin. 10111 is Guest.
      #####

      # Create a resource with scope=2 for the Group.

      # COPY resource_ (resourceid, codeid, primkey) FROM stdin;
      # +201	2	10166
      # +202	3	10301

      self.get_resource(:scope => 2)

      # Create a resource with scope=4 for this Layout.
      resource = self.get_resource(:scope => 4)
      logger.debug 'resource: %s' % resource.inspect

      # COPY permission_ (permissionid, companyid, actionid, resourceid) FROM stdin;
      # +301	10109	ADD_DISCUSSION	202
      # +302	10109	UPDATE	202
      # +303	10109	VIEW	202

      self.class.actions.each do |actionid|
        p = Permission.get(
          :companyid  => self.companyid,
          :actionid   => actionid,
          :resourceid => resource.id
        )

        # COPY users_permissions (userid, permissionid) FROM stdin;
        # +10129	301
        # +10129	302
        # +10129	303

        # admins can do everything
        self.company.administrators.each do |user|
          user.permissions << p
        end

        # COPY groups_permissions (groupid, permissionid) FROM stdin;
        # +10166	301
        # +10166	303

        # group members can ADD_DISCUSSION and VIEW
        if (actionid=='ADD_DISCUSSION' or actionid=='VIEW')
          self.group.permissions << p
        end

        # COPY users_permissions (userid, permissionid) FROM stdin;
        # +10111	303

        # guest is permitted to VIEW if the layout is public.
        if self.is_public? and actionid=='VIEW'
          self.company.guest.permissions << p
        end

      end

      # the layout management portlet (new in 5.2.x?)

      # COPY portletpreferences (portletpreferencesid, ownerid, ownertype, plid, portletid, preferences) FROM stdin;
      # +10259	0	3	10301	88	<portlet-preferences />

      # perhaps this will create itself?
      # Web::PortletPreferences.create(:plid => self.plid, :portletid => 88)

      return self
    end

    def save
      super
      if self.errors.any?
        logger.error self.errors.inspect
        raise self.errors[:layoutid] if self.errors[:layoutid]
      end
    end

    public

    belongs_to :group,
      :foreign_key => Group.primary_key

    belongs_to :company,
      :foreign_key => Company.primary_key

    has_many :resources,
      :foreign_key => 'primkey'

    def layoutset
      Web::LayoutSet.find(:first, :conditions => "groupid=#{self.groupid} AND privatelayout=#{self.privatelayout}" )
    end

    def portletids
      begin
        ts = self.typesettings
        c1= ts[/column-1=(.*)/,1] || ""
        c2= ts[/column-2=(.*)/,1] || ""
        c3= ts[/column-3=(.*)/,1] || ""
        (c1+c2+c3).split(",").uniq
      rescue
      end
    end

#--
#     def instanceids
#       self.portletids.map{|p| p if p[/INSTANCE/]}.compact.uniq
#     end
#++

    #
    def portlets
      portlets = []
      return portlets unless self.portletids # no portlets in this layout
      self.portletids.each do |id|
        # sometimes this returns portlets that do not belong to this layout
        portlets << (
          p = Web::PortletPreferences.find_by_portletid(id)
          if p
            p.layout = self
            p
          else
            Web::Portlet.find_by_portletid(id)
          end
        )
      end
      return portlets.compact
    end

    # Portlet instances on the Layout.
    def instances
      Web::PortletPreferences.find(:all, :conditions => "plid=#{self.plid} AND portletid LIKE '%INSTANCE%'")
    end

    def is_public?
      !self.privatelayout
    end

    def is_private?
      self.privatelayout
    end

    def is_hidden?
      self.hidden_
    end

    # the URL path to this Layout
    def path
      self.layoutset ? 
        self.layoutset.url_prefix + self.group.friendlyurl + self.friendlyurl : ''
    end

    # Settings for this Layout.
    #
    # Returns the object model of the string "typesettings".
    def settings
      Typesettings.new(self.typesettings)
    end

    # Save settings. Parses them to typesettings string.
    #
    # Parameters:
    #  - ts = Typesettings instance
    def settings=(ts)
      raise 'parameter must be a Typesettings instance' unless ts.is_a?(Typesettings)
      self.typesettings = ts.to_s
    end

    # As the method 'name' returns the name in XML, name_string is the string representation.
    def name_string
      self.name[/([^>]*)<\/name/,1]
    end

    # Insert the name string to XML.
    def name_string=(name)
      self.name = "<?xml version='1.0' encoding='UTF-8'?>"+\
      '<root available-locales="en_US" default-locale="en_US"><name language-id="en_US">%s</name></root>' % name
    end

    # sets the number of columns in this layout
    def columns=(nr)
      s = self.settings
      s.columns = nr
      self.settings = s
    end

    # Add a portlet to this layout.
    def <<(portlet, params={})
      unless portlet
        logger.debug 'No portlet given'
        return false
      end

      if portlet.is_a?(Web::PortletPreferences)
        preferences = portlet
        portlet = preferences.portlet
      else
        preferences = portlet.preferences
      end

      # define the layout
      preferences.layout = self
      preferences.save

      # not very OO..
      settings = self.settings
      location = (params[:location] ||= {:column => 1})
      #puts location.inspect

      # accept either a string or a symbol or Portlet
#       puts portlet.inspect
#       puts settings.portlets.inspect
      settings.portlets.update(
        location[:column] => [preferences || portlet]
      )
#       puts settings.portlets.inspect
      self.settings=settings

      [1,2].each do |scope|
        preferences.get_resource(:scope => scope)
      end

      # guest permissions are given if the layout is public.
      # (TODO: AND IF THE GROUP IS GUEST)

      resource = preferences.get_resource(:scope => 4)
      preferences.class.actions.each do |actionid|
        p = Permission.get(
          :companyid  => self.companyid,
          :actionid   => actionid,
          :resourceid => resource.id
        )
        if actionid=='VIEW'
          self.group.permissions << p
          if self.is_public?
            guest = self.company.guest
            guest.permissions << p
          end
        end
      end

      self
    end

  end
end
