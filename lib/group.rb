# This model represents the user groups (communities) in the lportal database.
class Group < ActiveRecord::Base
  set_table_name       :group_
  set_primary_key      :groupid

  public

  # com.liferay.portal.model.Group
  def liferay_class
    'com.liferay.portal.model.Group'
  end

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
      rc = self.resource_code(4)
      unless rc
        rc = ResourceCode.create(
          :companyid => self.companyid,
          :name => self.liferay_class,
          :scope => 4
        )
      end
      r = Resource.create(
        :codeid  => rc.id,
        :primkey => self.id
      )

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
        p = Permission.create(
          :companyid  => self.companyid,
          :actionid   => actionid,
          :resourceid => r.id
        )
        self.company.administrators.each do |user|
          user.user_permissions << p
        end
      end
    end
  end

  belongs_to :company,
    :foreign_key => 'companyid'

  belongs_to :creator,
    :class_name  => 'User',
    :foreign_key => 'creatoruserid'

  belongs_to :parent,
    :class_name  => 'Group',
    :foreign_key => 'parentgroupid'

  # association to organizations
  has_and_belongs_to_many  :organizations,
                           :join_table              => 'groups_orgs',
                           :foreign_key             => 'groupid',
                           :association_foreign_key => 'organizationid'
  alias :orgs :organizations

  # association to users
  has_and_belongs_to_many  :users,
                           :join_table              => 'users_groups',
                           :foreign_key             => 'groupid',
                           :association_foreign_key => 'userid'

  # association to roles
  has_and_belongs_to_many  :roles,
                           :join_table              => 'groups_roles',
                           :foreign_key             => 'groupid',
                           :association_foreign_key => 'roleid'

  # association to group permissions.
  has_and_belongs_to_many  :permissions,
                           :join_table              => 'groups_permissions',
                           :foreign_key             => 'groupid',
                           :association_foreign_key => 'permissionid'

  # association to group usergroups.
  has_and_belongs_to_many  :usergroups,
                           :join_table              => 'groups_usergroups',
                           :foreign_key             => 'groupid',
                           :association_foreign_key => 'usergroupid'

  ####

  # association to assets
  has_many :assets,
    :class_name  => 'Tag::Asset',
    :foreign_key => 'groupid'

  # a group may have two layoutsets (public and private)
  has_many :layoutsets,
    :class_name  => 'Web::LayoutSet',
    :foreign_key => 'groupid'

  has_one :public_layoutset,
    :class_name  => 'Web::LayoutSet',
    :foreign_key => 'groupid',
    :conditions  => 'privatelayout = false'

  has_one :private_layoutset,
    :class_name  => 'Web::LayoutSet',
    :foreign_key => 'groupid',
    :conditions  => 'privatelayout = true'

  # a group may have many layouts (public and private)
  has_many :layouts,
    :class_name  => 'Web::Layout',
    :foreign_key => 'groupid'

  has_many :public_layouts,
    :class_name  => 'Web::Layout',
    :foreign_key => 'groupid',
    :conditions  => 'privatelayout = false'

  has_many :private_layouts,
    :class_name  => 'Web::Layout',
    :foreign_key => 'groupid',
    :conditions  => 'privatelayout = true'


  # --
  # Class methods
  # ++

  class << self

    # 0 = personal user groups
    def find_personal(companyid)
      self.find(:all, :conditions => "companyid=#{companyid} AND type_=0")
    end

    # 1 = public, guest can see
    def find_public(companyid)
      self.find(:all, :conditions => "companyid=#{companyid} AND type_=1")
    end

    # 2 = user-created open communities
    def find_open(companyid)
      self.find(:all, :conditions => "companyid=#{companyid} AND type_=2")
    end

    # 3 = private, also contains admins
    def find_private(companyid)
      self.find(:all, :conditions => "companyid=#{companyid} AND type_=3")
    end
  end


  # --
  # Instance methods
  # ++

  # Group's name. If classnameid==0 (Group is a basic group), use the name in the group_ column.
  # Otherwise use the owner's name.
  def name
    self.classnameid != 0 ?
      self.owner.name : super
  end

  # find owner by classnameid + classpk
  def owner
    return nil if self.classnameid==0
    _class = Classname.model(Classname.find(self.classnameid).value)
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


  has_one :resource,
    :foreign_key => 'primkey'

  has_many :mbcategories,
    :class_name  => 'MB::Category',
    :foreign_key => 'groupid'

  def is_active?
    self.active_
  end

  def is_public?
    self.type_ == 1
  end

  def is_protected?
    self.type_ == 2
  end

  def is_private?
    self.type_ == 3
  end

  # URL path to this Group's public or private page
  def path(pl=:public)
    case pl
    when :public
      self.public_layouts.any? ?
        self.public_layoutset.url_prefix + self.friendlyurl : nil

    when :private
      self.private_layouts.any? ?
        self.private_layoutset.url_prefix + self.friendlyurl : nil

    else
      nil
    end
  end

  # ResourceCode associated to this instance (and scope)
  def resource_code(scope=4)
    ResourceCode.find(:first,
      :conditions => "companyid=#{self.companyid} AND name='#{self.liferay_class}' AND scope=#{scope}")
  end

  # Selects the layout (from both public and private) that has the portlet.
  # Parameters:
  #  - portlet     can be either a String of portlet name (eg. 'message_boards') or a Web::PortletName instance.
  #  - pl          only check public or private layouts? defaults to both. ( nil | :public | :private )
  def select_layouts_with(portlet,pl=nil)
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

    layouts.select{|l| l.settings.include?(portlet)}
  end

  # Does any of the layouts include this portlet? See #select_layouts_with
  def layouts_include?(portlet,pl=nil)
    self.select_layouts_with(portlet,pl).any?
  end

  # Helper to collect all tags that are related to this Group through Tag::Asset.
  def assets_tags
    self.assets.collect(&:tags).flatten.uniq
  end

end