module Web
  # Page layouts. These are individual layouts for items in the navigation bar.
  # Layouts have portlets, these are modeled by parsing (by regexp) the typesettings xml. Layouts belong to a certain LayoutSet.
  class Layout < ActiveRecord::Base
    set_table_name       :layout
    set_primary_key      :plid

    validates_uniqueness_of :layoutid, :scope => [:groupid, :privatelayout]


    # com.liferay.portal.model.Layout
    def liferay_class
      'com.liferay.portal.model.Layout'
    end

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

      # perhaps layoutid could be sequenced.
      layouts = (self.is_public? ? self.group.public_layouts : self.group.private_layouts)
      _ids = (layouts.any? ? layouts.collect(&:layoutid) : nil)
      self.layoutid = (_ids.nil? ? 1 : _ids.sort.max+1)

      # increment pagecount
      _set = self.layoutset
      _set.pagecount += 1
      _set.save

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

      rc = self.resource_code(2)
      unless rc
        rc = ResourceCode.create(
          :companyid => self.companyid,
          :name => self.liferay_class,
          :scope => 2
        )
      end
      unless Resource.find(:first, :conditions => "codeid=#{rc.id} AND primkey='#{self.group.id}'")
        Resource.create(
          :codeid  => rc.id,
          :primkey => self.group.id
        )
      end

      # Create a resource with scope=4 for this Layout.
      rc = self.resource_code(4)
      unless rc
        rc = ResourceCode.create(
          :companyid => self.companyid,
          :name => self.liferay_class,
          :scope => 4
        )
      end
      resource = Resource.create(
        :codeid  => rc.id,
        :primkey => self.id
      )

      # COPY permission_ (permissionid, companyid, actionid, resourceid) FROM stdin;
      # +301	10109	ADD_DISCUSSION	202
      # +302	10109	UPDATE	202
      # +303	10109	VIEW	202

      self.class.actions.each do |actionid|
        p = Permission.create(
          :companyid  => self.companyid,
          :actionid   => actionid,
          :resourceid => resource.id
        )

        # COPY users_permissions (userid, permissionid) FROM stdin;
        # +10129	301
        # +10129	302
        # +10129	303
        # +10111	303

        self.company.administrators.each do |user|
          user.user_permissions << p
        end

        # COPY groups_permissions (groupid, permissionid) FROM stdin;
        # +10166	301
        # +10166	303
        group = self.group
        self.group.permissions << p
      end
      return self
    end

    public

    belongs_to :group,
      :foreign_key => 'groupid'

    belongs_to :company,
      :foreign_key => 'companyid'

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
  
#     def instanceids
#       self.portletids.map{|p| p if p[/INSTANCE/]}.compact.uniq
#     end
  
    #
    def portlets
      portlets = []
      return portlets unless self.portletids
      self.portletids.each do |id|
        portlets << (Web::Portlet.find_by_portletid(id) or Web::PortletPreferences.find_by_portletid(id))
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
      self.layoutset.url_prefix + self.group.friendlyurl + self.friendlyurl
    end

    # ResourceCode associated to this instance (and scope)
    def resource_code(scope=4)
      ResourceCode.find(:first,
        :conditions => "companyid=#{self.companyid} AND name='#{self.liferay_class}' AND scope=#{scope}")
    end

    def contents
      Typesettings.new(self.typesettings)
    end

  end
end
