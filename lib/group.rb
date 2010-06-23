# encoding: utf-8

# This model represents the user groups (communities) in the lportal database.
class Group < ActiveRecord::Base

  acts_as_resourceful

  # Actions for Permissions.
  def self.actions
    %w{
    APPROVE_PROPOSAL
    ASSIGN_MEMBERS
    ASSIGN_REVIEWER
    DELETE
    MANAGE_ANNOUNCEMENTS
    MANAGE_ARCHIVED_SETUPS
    MANAGE_LAYOUTS
    MANAGE_STAGING
    PERMISSIONS
    PUBLISH_STAGING
    UPDATE
    }
  end

  # Creates a new group (community).
  #
  #
  # Some instances are created based on the Classname of the Group.
  # User's own group, for instance, has to be created with classnameid and classpk.
  #
  # The Group may also have public and private Web::LayoutSet s.
  #
  # This process is engineered by creating a new role with Liferay's (v. 5.1.1) tools and
  # inspecting the database dump diffs.
  #
  # Mandatory parameters:
  #  - companyid
  #  - creatoruserid
  def initialize(params)
    raise 'No companyid given' unless (params[:companyid] or params[:company])
    raise 'No creatoruserid given' unless params[:creatoruserid]
    raise 'No name given' if (
      params[:name].nil? and (params[:classnameid].nil? or params[:classnameid]==0))

    super(params)

    # COPY group_ (groupid, companyid, creatoruserid, classnameid, classpk, parentgroupid, livegroupid, name, description, type_, typesettings, friendlyurl, active_) FROM stdin;
    # +10155	10109	10129	0	0	0	0	testiyhteisö open	testataan yhteisön luomista	1		/10155	t

    self.classnameid   ||= 0 # Community
    self.classpk       ||= 0 # -"-
    self.parentgroupid ||= 0
    self.livegroupid   ||= 0
    self.name          ||= ''
    self.description   ||= ''
    self.type_         ||= 1
    self.typesettings  ||= ''
    self.active_       ||= true

    unless self.friendlyurl
      self.friendlyurl = (
        case self.classnameid
        when 0
          '/'+self.name.downcase
        else
          self.friendlyurl   ||= '/%i' % self.id
        end
      )
    end

    self.save

    # public and private layoutsets

    # COPY layoutset (layoutsetid, groupid, companyid, privatelayout, logo, logoid, themeid, colorschemeid, wapthemeid, wapcolorschemeid, css, pagecount, virtualhost) FROM stdin;
    # +10156	10155	10109	t	f	0		01	mobile	01		0	
    # +10157	10155	10109	f	f	0		01	mobile	01		0	

    [true, false].each do |privacy|
      Web::LayoutSet.create(
        :groupid       => self.id,
        :companyid     => self.companyid,
        :privatelayout => privacy
      )
    end

    ### GROUP
    unless self.classnameid == 0
      # Type is != 0 only for Groups of type Group (?)
      self.type_ = 0
      self.save
    else

      # COPY resource_ (resourceid, codeid, primkey) FROM stdin;
      # +41	6	10155
      # 
      # Create a resource with scope=4 for this Layout.
      r = get_resource(:scope => 4)

      # Permissions (given to administrators)

      # 
      # COPY permission_ (permissionid, companyid, actionid, resourceid) FROM stdin;
      # +81	10109	APPROVE_PROPOSAL	41
      # +82	10109	ASSIGN_MEMBERS	41
      # +83	10109	ASSIGN_REVIEWER	41
      # +84	10109	DELETE	41
      # +85	10109	MANAGE_ANNOUNCEMENTS	41
      # +86	10109	MANAGE_ARCHIVED_SETUPS	41
      # +87	10109	MANAGE_LAYOUTS	41
      # +88	10109	MANAGE_STAGING	41
      # +89	10109	PERMISSIONS	41
      # +90	10109	PUBLISH_STAGING	41
      # +91	10109	UPDATE	41
      # 

      self.class.actions.each do |actionid|
        p = Permission.get(
          :companyid  => self.companyid,
          :actionid   => actionid,
          :resourceid => r.id
        )
        self.company.administrators.each do |user|
          user.permissions << p
        end
      end
    end
  end

  belongs_to :company,
    :foreign_key => Company.primary_key

  belongs_to :creator,
    :class_name  => 'User',
    :foreign_key => 'creatorUserId' # FIXME: breaks PostgreSQL

  belongs_to :parent,
    :class_name  => 'Group',
    :foreign_key => 'parentGroupId' # FIXME: breaks PostgreSQL

  # association to organizations
  has_and_belongs_to_many  :organizations,
                           :join_table              => 'Groups_Orgs',
                           :foreign_key             => self.primary_key,
                           :association_foreign_key => Organization.primary_key
  alias :orgs :organizations

  # association to users
  has_and_belongs_to_many  :users,
                           :join_table              => 'Users_Groups',
                           :foreign_key             => self.primary_key,
                           :association_foreign_key => User.primary_key

  # association to roles
  has_and_belongs_to_many  :roles,
                           :join_table              => 'Groups_Roles',
                           :foreign_key             => self.primary_key,
                           :association_foreign_key => Role.primary_key

  # association to group permissions.
  has_and_belongs_to_many  :permissions,
                           :join_table              => 'Groups_Permissions',
                           :foreign_key             => self.primary_key,
                           :association_foreign_key => Permission.primary_key

  # association to group usergroups.
  has_and_belongs_to_many  :usergroups,
                           :join_table              => 'Groups_UserGroups',
                           :foreign_key             => self.primary_key,
                           :association_foreign_key => Usergroup.primary_key

  ####

  # association to assets
  has_many :assets,
    :class_name  => 'Tag::Asset',
    :foreign_key => self.primary_key

  has_many :mbcategories,
    :class_name => 'MB::Category',
    :foreign_key => self.primary_key

  # a group may have two layoutsets (public and private)
  has_many :layoutsets,
    :class_name  => 'Web::LayoutSet',
    :foreign_key => self.primary_key

  has_one :public_layoutset,
    :class_name  => 'Web::LayoutSet',
    :foreign_key => self.primary_key,
    :conditions  => 'privatelayout = false' # FIXME

  has_one :private_layoutset,
    :class_name  => 'Web::LayoutSet',
    :foreign_key => self.primary_key,
    :conditions  => 'privatelayout = true' # FIXME

  # a group may have many layouts (public and private)
  has_many :layouts,
    :class_name  => 'Web::Layout',
    :foreign_key => self.primary_key

  has_many :public_layouts,
    :class_name  => 'Web::Layout',
    :foreign_key => self.primary_key,
    :conditions  => 'privatelayout = false' # FIXME

  has_many :private_layouts,
    :class_name  => 'Web::Layout',
    :foreign_key => self.primary_key,
    :conditions  => 'privatelayout = true' # FIXME


  # --
  # Class methods
  # ++

  class << self

    # 0 = personal user groups
    def find_personal(companyid)
      self.find(:all, :conditions => "#{Company.primary_key}=#{companyid} AND type_=0")
    end

    # 1 = public, guest can see
    def find_public(companyid)
      self.find(:all, :conditions => "#{Company.primary_key}=#{companyid} AND type_=1")
    end

    # 2 = user-created open communities
    def find_open(companyid)
      self.find(:all, :conditions => "#{Company.primary_key}=#{companyid} AND type_=2")
    end

    # 3 = private, also contains admins
    def find_private(companyid)
      self.find(:all, :conditions => "#{Company.primary_key}=#{companyid} AND type_=3")
    end
  end


  # --
  # Instance methods
  # ++

  # Group's name. If classnameid==0 (Group is a basic group), use the name in the group_ column.
  # Otherwise use the owner's name.
  #
  # DEPRECATED.
  # Liferay has a column "name" since 5.2.x?
  def name
    # TODO: if-else Liferay version
    super
    #self.classnameid != 0 ?
    #  self.owner.name : super
  end

  # find owner by classnameid + classpk
  def owner
    return nil if self.classnameid==0
    _class = Classname.model(Classname.find(self.classnameid).value)
    return nil unless _class
    _class.find self.classpk
  end

  # Members by the group type, ie. if the group is of type Organization, return Organization members.
  def members
    if self.owner.kind_of?(Organization)
      return self.owner.members
    else
      #[self.users, self.organizations.collect(&:users)].flatten
      return self.users
    end
  end

  # Assign User to be a member of this Group
  def assign_membership(user)
    raise 'TODO'
    # COPY usergrouprole (userid, groupid, roleid) FROM stdin;
    # +10129	10155	10120
    # +10129	10155	10119
    # 
    # COPY users_groups (userid, groupid) FROM stdin;
    # +10129	10155
    # 
  end

  def is_active?
    self.active_
  end

  # column type_ changed in Liferay 5.2.x

#   def is_personal?
#     self.type_ == 0
#   end

#   def is_public?
#     self.type_ == 1
#   end

#   def is_protected?
#     self.type_ == 2
#   end

#   def is_private?
#     self.type_ == 3
#   end

  # URL path to this Group's public or private page
  def path(pl=:public)
    case pl
    when :public
      self.public_layouts.any? ?
        self.public_layoutset.url_prefix + self.friendlyurl : ''

    when :private
      self.private_layouts.any? ?
        self.private_layoutset.url_prefix + self.friendlyurl : ''

    else
      ''
    end
  end

  # Selects the layout (from both public and private) that has the portlet.
  #
  # Parameters:
  #  - portlet     can be either a String of portlet name (eg. 'message_boards'),
  #                or a Web::Portlet, Web::PortletPreferences or Web::PortletProperties instance.
  #  - pl          only check public or private layouts? defaults to both. ( nil | :public | :private )
  #
  def select_layouts_with(portlet,pl=nil)
    name = (portlet.is_a?(String) ? portlet : portlet.name)
    layouts = (
      if pl.nil?
        self.layouts
      elsif pl==:public
        self.public_layouts
      elsif pl==:private
        self.private_layouts
      else
        []
      end
    )

#     layouts.select{|l| l.settings.include?(portlet)}
    layouts.select do |l|
      l.portlets.map {|p| p.name==name}.any?
    end
  end

  # Does any of the layouts include this portlet? See #select_layouts_with
  def layouts_include?(portlet,pl=nil)
    self.select_layouts_with(portlet,pl).any?
  end

  # Helper to collect all tags that are related to this Group through Tag::Asset.
  def assets_tags
    self.assets.collect(&:tags).flatten.uniq
  end

  # Unless the tagged_content portlet is found in any of the groups layouts,
  # a new layout (public by default) is created with this portlet.
  #
  # See #select_layouts_with
  #
  # The asset viewer is different in different versions of the Liferay database.
  #  - 5.1.x: tagged_content
  #  - 5.2.x: asset_publisher
  def asset_viewer_portlet(params={})
    if Lportal::Schema.buildnumber < 5200
      logger.debug 'Using lportal schema 5.1.x'
      params[:name] ||= 'tagged_content'
    else
      logger.debug 'Using lportal schema 5.2.x'
      params[:name] ||= 'asset_publisher'
    end

    # first locate the portlet
    portlet = Web::Portlet.find_by_name(params[:name])
    raise ('Portlet ”%s” not found! Check that Caterpillar migrations are up-to-date' % params[:name]) unless portlet

    # if <tt>pl</tt> is undefined, use public layout, else use what <tt>pl</tt> specified.
    params.update(:privatelayout => ( params[:privatelayout].nil? ? false : params[:privatelayout] ))
    pl = (params[:privatelayout]==true ? :private : :public) # a small "type conversion"
    layouts = self.select_layouts_with(portlet,pl)

    # select the portlet from existing layouts
    if layouts.any?
      logger.debug 'Layout with tagged_content portlet found..'
      layout = layouts.first
      layout.portlets.each do |p|
        return p if p.name==portlet.name
      end
    end

    ### Create Layout + PortletPreferences
    logger.info 'Creating new Layout ”%s” in Group %s (%i)' % [params[:name],self.name,self.id]

    params[:friendlyurl] ||= ('/%s' % params[:name])
    params.update(:group => self)

    layout = Web::Layout.create(params)
    logger.debug 'Layout ready'
    logger.debug layout.inspect

    layout.settings = Web::Typesettings.new
    layout.columns=1

    # add the portlet to the layout
    layout.<<( portlet )
    layout.save

    portlet.reload
    logger.debug portlet.preferences.inspect
    return portlet.preferences
  end

end