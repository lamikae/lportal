# encoding: utf-8

class User < ActiveRecord::Base

  acts_as_resourceful

  validates_uniqueness_of :uuid_
  validates_uniqueness_of :emailaddress, :scope => Company.primary_key
  validates_uniqueness_of :screenname,   :scope => Company.primary_key

  public

  # Actions for Permissions.
  def self.actions
    %w{ DELETE IMPERSONATE PERMISSIONS UPDATE VIEW }
  end

  # Creates a new user.
  #
  # It is a complicated process, as Liferay inserts new data into many tables.
  # This process is engineered by creating a new role with Liferay's (v. 5.1.1) tools and
  # inspecting the database dump diffs.
  #
  # Does not (yet) work on MySQL.
  #
  # Mandatory parameters:
  #  - companyid
  #  - firstname
  #  - lastname
  #  - emailaddress
  def initialize(params)
    raise 'No companyid given' unless (params[:companyid] or params[:company])
    raise 'No firstname' unless params[:firstname]
    raise 'No lastname' unless params[:lastname]
    raise 'No emailaddress' unless params[:emailaddress]
    # Do not create Contact before creating self!
    firstname = params.delete(:firstname)
    lastname = params.delete(:lastname)
    # Do not create contact before creating self!
    gsm = params.delete(:gsm)
    male = params.delete(:male)

    super(params)

    # COPY user_ (uuid_, userid, companyid, createdate, modifieddate, defaultuser, contactid, password_, passwordencrypted, passwordreset, passwordmodifieddate, gracelogincount, screenname, emailaddress, openid, portraitid, languageid, timezoneid, greeting, comments, logindate, loginip, lastlogindate, lastloginip, lastfailedlogindate, failedloginattempts, lockout, lockoutdate, agreedtotermsofuse, active_) FROM stdin;
    # +c130e60d-d85a-40b8-b778-e0c0c868e508	10164	10109	2009-01-15 00:51:58.558	2009-01-15 00:51:58.558	f	10165	jGrep/LZ9ghV6N1IJ5iWcH3d4ps=	t	f	\N	0	teppo	teppo@localhost.localdomain		0	en_US	GMT	Welcome Teppo Testaaja!		\N		\N		\N	0	f	\N	f	t

    # insert data into user_
    unless self.uuid_
      require 'rubygems'
      require 'uuidtools'
      self.uuid_ = UUID.random_create.to_s
    end
    self.createdate          = Time.now
    self.modifieddate        = Time.now
    self.defaultuser         = false
    unless self.password_
      self.password_         = firstname
      self.passwordencrypted = false
    end
    self.passwordreset=false if self.passwordreset.nil?
    self.gracelogincount     = 0
    self.screenname          ||= [firstname, lastname].join('-').downcase
    self.emailaddress        ||= ''
    self.portraitid          ||= 0
    self.languageid          ||= ''
    self.timezoneid          ||= 'Europe/Istanbul'
    self.greeting            ||= 'Welcome'
    self.comments            ||= ''
    self.loginip             ||= ''
    self.lastloginip         ||= ''
    self.failedloginattempts = 0
    self.lockout             = false
    self.agreedtotermsofuse  = true
    self.active_ = true if self.active_.nil?
    self.openid              ||= ''

    self.save
    self.reload

    # create new contact

    # COPY contact_ (contactid, companyid, userid, username, createdate, modifieddate, accountid, parentcontactid, firstname, middlename, lastname, prefixid, suffixid, male, birthday, smssn, aimsn, facebooksn, icqsn, jabbersn, msnsn, myspacesn, skypesn, twittersn, ymsn, employeestatusid, employeenumber, jobtitle, jobclass, hoursofoperation) FROM stdin;
    # +10165	10109	10129	Test Test	2009-01-15 00:51:58.558	2009-01-15 00:51:58.558	10110	0	Teppo		Testaaja	0	0	t	1970-01-01 00:00:00						

    if male.is_a?(String)
      male = (male=='true')
    end
    self.contact = Contact.create({
      :userid => self.id,
      :username => '', # name of the user who created this user
      :firstname => firstname,
      :lastname => lastname,
      :male => male
    })

    # assign "User" and "Power User" roles

    # COPY users_roles (userid, roleid) FROM stdin;
    # +10164	10116
    # +10164	10117

    self.roles << Role.find(:first, :conditions => "companyid=#{self.companyid} AND name='User'")
    self.roles << Role.find(:first, :conditions => "companyid=#{self.companyid} AND name='Power User'")

    # Personal group

    # COPY group_ (groupid, companyid, creatoruserid, classnameid, classpk, parentgroupid, livegroupid, name, description, type_, typesettings, friendlyurl, active_) FROM stdin;
    # +10166	10109	10164	10034	10164	0	0			0		/teppo	t

    g = Group.create(
      :companyid     => self.companyid,
      :creatoruserid => self.id,
      :classnameid   => Classname.find_by_value(self.liferay_class).id,
      :classpk       => self.id,
      :friendlyurl   => '/'+self.screenname
    )

    # Group's public + private layoutsets (should be created only for Power Users?)
    # are created in the Group model.

    # COPY layoutset (layoutsetid, groupid, companyid, privatelayout, logo, logoid, themeid, colorschemeid, wapthemeid, wapcolorschemeid, css, pagecount, virtualhost) FROM stdin;
    # +10167	10166	10109	t	f	0		01	mobile	01		0	
    # +10168	10166	10109	f	f	0		01	mobile	01		0	



    # insert data into counter_ so that Hibernate won't die
#     Counter.increment(:resource, 100)

    # COPY resource_ (resourceid, codeid, primkey) FROM stdin;
    # +44	5	10164

    # scope=4 means that the resource is "owned" by User
    resource = get_resource(:scope => 4)


    # COPY permission_ (permissionid, companyid, actionid, resourceid) FROM stdin;
    # +114	10109	DELETE	44
    # +115	10109	IMPERSONATE	44
    # +116	10109	PERMISSIONS	44
    # +117	10109	UPDATE	44
    # +118	10109	VIEW	44

    # COPY users_permissions (userid, permissionid) FROM stdin;
    # +10129	114
    # +10129	115
    # +10129	116
    # +10129	117
    # +10129	118

    # insert data into counter_ so that Hibernate won't die
#     Counter.increment(:permission, 100)
    self.class.actions.each do |action|
      self.permissions << Permission.get(
        :companyid  => self.companyid,
        :actionid   => action,
        :resourceid => resource.id
      )
    end

    # announcementsdelivery

    # COPY announcementsdelivery (deliveryid, companyid, userid, type_, email, sms, website) FROM stdin;
    # +10169	10109	10164	general	f	f	t
    # +10170	10109	10164	news	f	f	t
    # +10171	10109	10164	test	f	f	t

    %w{ general news test }.each do |type|
      Announcement::Delivery.create(
        :userid    => self.id,
        :companyid => self.companyid,
        :type_     => type,
        :email     => false,
        :sms       => false,
        :website   => true
      )
    end

    self.save

    # insert data into phone
    self.gsm=gsm if gsm
    return self
  end

  def save
    super

    raise self.errors[:uuid_] if self.errors[:uuid_]
    raise self.errors[:emailaddress] if self.errors[:emailaddress]
    raise self.errors[:screenname] if self.errors[:screenname]
  end

  has_one :account, :foreign_key => self.primary_key

  has_many :phones, :foreign_key => self.primary_key

  belongs_to :contact, :foreign_key => Contact.primary_key

  belongs_to :company, :foreign_key => Company.primary_key

  # TODO: fix these associations for Mysql

  # association to organizations
  has_and_belongs_to_many  :organizations,
                           :join_table              => 'users_orgs',
                           :foreign_key             => 'userid',
                           :association_foreign_key => 'organizationid'
  alias :orgs :organizations

  # association to groups
  has_and_belongs_to_many  :groups,
                           :join_table              => 'users_groups',
                           :foreign_key             => 'userid',
                           :association_foreign_key => 'groupid'
  alias :communities :groups

  # association to roles
  has_and_belongs_to_many  :roles,
                           :join_table              => 'users_roles',
                           :foreign_key             => 'userid',
                           :association_foreign_key => 'roleid'

  # association to direct user permissions.
  has_and_belongs_to_many  :permissions,
                           :class_name              => 'Permission',
                           :join_table              => 'users_permissions',
                           :foreign_key             => 'userid',
                           :association_foreign_key => 'permissionid'

  # association to usergroups
  has_and_belongs_to_many  :usergroups,
                           :class_name              => 'Usergroup',
                           :join_table              => 'users_usergroups',
                           :foreign_key             => 'userid',
                           :association_foreign_key => 'usergroupid'

  # User's own group
  has_one :hive,
    :class_name => 'Group',
    :foreign_key => 'classpk'

  # association to tags
  has_many :tags,
           :class_name => 'Tag::Entry',
           :foreign_key => self.primary_key

  # association to assets
  has_many :assets,
           :order       => 'publishdate',
           :foreign_key => self.primary_key

  # association to wiki pages
  has_many :wikipages,
    :class_name  => 'Wiki::Page',
    :foreign_key => self.primary_key
  alias :articles :wikipages

  # association to MessageBoardMessages
  has_many :mbmessages,
           :class_name  => 'MB::Message',
           :foreign_key => self.primary_key


  def group_permissions
    self.groups.map{|g| g.permissions }.flatten
  end

  def role_permissions
    self.roles.map{|g| g.permissions }.flatten
  end

  # All permissions that the user has.
  # Permissions are summed up from user, group and role permissions.
  def all_permissions
    (self.permissions + group_permissions + role_permissions).flatten
  end


  # Adds User to Organization members.
  # TODO: move to Organization
  #
  # Updates users_organizations, adds the 'Organization Member' Role,
  # and updates 3-way associations to usergrouprole.
  def assign_organization_membership(org)
    # organization membership
    org = self.company.organizations.select{|o| o.parent==nil}.first
    self.organizations << org

    # give the user the 'Organization member' role, within the scope of this Organization.
    org_role = Role.find(:first, :conditions => "companyid=#{self.companyid} AND name='Organization Member'")
    group = org.group

    # can ActiveRecord handle 3-way associations?
    # - perhaps with hacking, http://bjhess.com/blog/2007/09/19/my-foray-into-has_many_polymorphs/
    ActiveRecord::Base.connection.execute(
      "INSERT INTO usergrouprole (userid, groupid, roleid) VALUES (%i, %i, %i);" % [
        self.id, org.group.id, org_role.id])

    true
  end


  # Fullname is fetched from Contact
  def name
    self.contact ?
      self.contact.fullname : nil
  end
  alias :fullname :name

  def firstname
    self.contact ?
      self.contact.firstname : nil
  end
  # Creates a new Contact unless it exists
  def firstname=(v)
    if self.contact
      c = self.contact
      c.firstname = v
      c.save
    else
      c = Contact.create(
        :user => self,
        :firstname => v )
      self.contact = c
      self.save
    end
    true
  end
  def lastname
    self.contact ?
      self.contact.lastname : nil
  end
  # Creates a new Contact unless it exists
  def lastname=(v)
    if self.contact
      c = self.contact
      c.lastname = v
      c.save
    else
      c = Contact.create(
        :user => self,
        :lastname => v )
      self.contact = c
      self.save
    end
    true
  end

  # Sex. 0=female, 1=male
  def sex
    self.contact.male==true ? 1 : 0
  end

  # Creates a new Contact unless it exists
  #
  # 0=female, 1=male
  def sex=(v)
    male = (v==0 ? false : true)
    if self.contact
      c = self.contact
      c.male=male
      c.save
    else
      c = Contact.create(
        :user => self,
        :male => male )
      self.contact = c
      self.save
    end
    true
  end


#   def address
#     self.address || Address.new(:user=>self, :company=>self.company)
#   end

  # Creates a Address, unless one exists.
  def address
    return @address if @address
    @address = Address.find_by_userid self.id
    if @address.nil?
      @address = Address.new(
        :user => self,
        :createdate => Time.now,
        :company => self.company)
    end
    return @address
  end

  def lang
    self.languageid
  end
  def lang=(value)
    self.languageid=value
    true
  end

  # Perhaps it would make more sense to select phones with classnameid of "mobile"
  def gsm
    self.phones.any? ? self.phones.first.number : nil
  end
  # Creates a new Phone unless it exists
  def gsm=(number)
    _number = self.class.cleanup_mobile_number(number)
    return false if _number.empty? # no not save empty numbers

    if self.phones.any?
      phone = self.phones.first
      phone.number=_number
      phone.save
    else
      Phone.create(
        :user => self,
        :number_ => _number,
        :primary_ => true
      )
      self.phones.reload
    end
    true
  end

  # This method is meant to be overridden in custom configurations.
  def self.cleanup_mobile_number(number)
    return number
  end

  def birthday
    self.contact.birthday
  end
  # FIXME: should create a new Contact
  def birthday=(val)
    self.contact.birthday = val
    self.contact.save
  end

  def streetaddress
    self.address.street1
  end
  # FIXME: should create a new Address
  def streetaddress=(val)
    self.address.street1 = val
    self.address.save
  end

  def zipcode
    self.address.zip
  end
  # FIXME: should create a new Address
  def zipcode=(val)
    self.address.zip = val
    self.address.save
  end

  def city
    self.address.city
  end
  # FIXME: should create a new Address
  def city=(val)
    self.address.city = val
    self.address.save
  end

  # Resources associated to this instance
  def resources
    Resource.find(:all, :conditions => "primkey='#{self.id}'")
  end

  def is_active?
    self.active_
  end

  def is_default?
    self.defaultuser
  end
  alias :is_guest? :is_default?

  # Activates inactive users. Makes it easy to extend functionality with mixins (to send email, for example).
  def activate
    self.active_ = true
    self.save
    self.class.instance_method_already_implemented?(:activate) ?
      super : true
  end

  # Deactivates active users
  def deactivate
    self.active_ = false
    self.save
    self.class.instance_method_already_implemented?(:deactivate) ?
      super : true
  end

  # URL path to this User's public or private page
  def path(pl=:public)
    self.hive.nil? ? '' : self.hive.path(pl)
  end

  # URL to user's portrait (needs to be prefixed with Liferay server URL).
  # Unless the user has a portrait, a default image should be displayed.
  def portrait_path
    gender = (
      if self.contact
        self.contact.male ? 'male' : 'female'
      else
        'male'
      end
    )
    path = '/image/user_%s_portrait' % gender
    path << "?img_id=#{self.portraitid}" if self.portraitid != 0
    return path
  end

end
