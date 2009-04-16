# Message Board
module MB
  class Category < ActiveRecord::Base

    acts_as_resourceful

    # this causes trouble when modifying instance attributes (!)
    #validates_uniqueness_of :uuid_

    # Actions for Permissions.
    def self.actions
      %w{
        ADD_FILE
        ADD_MESSAGE
        ADD_SUBCATEGORY
        DELETE
        MOVE_THREAD
        PERMISSIONS
        REPLY_TO_MESSAGE
        SUBSCRIBE
        UPDATE
        UPDATE_THREAD_PRIORITY
        VIEW
      }
    end

    # Creates a new Message Board category.
    #
    # This process is engineered by creating a new layout with Liferay's (v. 5.1.1) tools and
    # inspecting the database dump diffs.
    #
    # Mandatory parameters:
    #  - groupid
    #  - name
    def initialize(params)
      raise 'No groupid given' unless (params[:groupid] or params[:group])
      raise 'No name given' unless params[:name]
      super(params)

      # COPY mbcategory (uuid_, categoryid, groupid, companyid, userid, username, createdate, modifieddate, parentcategoryid, name, description, lastpostdate) FROM stdin;
      # +fda18eef-3992-419e-a373-6e2f01a8b6a9	10307	10166	10109	10129	Test Test	2009-01-17 08:06:00.359	2009-01-17 08:06:00.359	0	Teppo Testaaja	message board for user Teppo	\N

      unless self.uuid_
        require 'rubygems'
        require 'uuidtools'
        self.uuid_ = UUID.random_create.to_s
      end

      self.companyid = self.group.companyid

      # owner (if undefined, use admin)
      unless self.userid
        user = Company.first.administrators.first
        self.userid   ||= user.id
      end
      self.username         ||= self.user.fullname
      self.createdate       = Time.now
      self.modifieddate     = Time.now
      self.parentcategoryid ||= 0
      self.description      ||= ''

      self.save

      # ResourceCode with scope 1 => Resource for Company
      # ResourceCode with scope 2 => Resource for this Group and Guest's Group
      # ResourceCode with scope 4 => Resource for self

      # COPY resourcecode (codeid, companyid, name, scope) FROM stdin;
      # +104	10109	com.liferay.portlet.messageboards.model.MBCategory	1
      # +105	10109	com.liferay.portlet.messageboards.model.MBCategory	2
      # +106	10109	com.liferay.portlet.messageboards.model.MBCategory	4

      # COPY resource_ (resourceid, codeid, primkey) FROM stdin;
      # +210	104	10109
      # +211	105	10124
      # +212	105	10166
      # +213	106	10307

      # COPY permission_ (permissionid, companyid, actionid, resourceid) FROM stdin;
      # +312	10109	ADD_FILE	213
      # +313	10109	ADD_MESSAGE	213
      # +314	10109	ADD_SUBCATEGORY	213
      # +315	10109	DELETE	213
      # +316	10109	MOVE_THREAD	213
      # +317	10109	PERMISSIONS	213
      # +318	10109	REPLY_TO_MESSAGE	213
      # +319	10109	SUBSCRIBE	213
      # +320	10109	UPDATE	213
      # +321	10109	UPDATE_THREAD_PRIORITY	213
      # +322	10109	VIEW	213

      # COPY users_permissions (userid, permissionid) FROM stdin;
      # +10129	312
      # +10129	313
      # +10129	314
      # +10129	315
      # +10129	316
      # +10129	317
      # +10129	318
      # +10129	319
      # +10129	320
      # +10129	321
      # +10129	322

      get_resource(:scope => 1)
      get_resource(:scope => 2)

      # Permissions to scope 4

      self.class.actions.each do |actionid|
        self.user.permissions << permission(actionid,4)
      end
    end

    # Finds existing or creates a new Resource (TODO: DRY up!!)
    # Args Hash:
    #  - :codeid
    #  - :primkey
    def self.get(args)
      conditions = []
      args.each_pair{ |k,v|
        conditions << (k==:name ?
          ("%s='%s'" % [k,v]) : ("%s=%s" % [k,v]))
      }
      #puts conditions.inspect
      r = self.find(:first, :conditions => conditions.join(' AND '))
      unless r
        logger.debug 'creating new %s' % self.class
        r = self.create(args)
      end
      return r
    end

    belongs_to :group,
      :foreign_key => "groupid"

    belongs_to :company,
      :foreign_key => "companyid"

    belongs_to :user,
      :foreign_key => "userid"
    alias :owner :user

    has_one :asset,
      :foreign_key => 'classpk'

#     has_one :parent,
#       :class_name => self.class,
#       :foreign_key => "parentcategoryid"

    # Parent Category, nil if this is already root.
    def parent
      self.parentcategoryid != 0 ? MB::Category.find(self.parentcategoryid) : nil
    end

    has_many :subcategories,
      :class_name => 'MB::Category',
      :foreign_key => :parentcategoryid

    has_many :threads,
      :class_name  => 'MB::Thread',
      :foreign_key => 'categoryid',
      :order       => 'lastpostdate DESC'

    has_many :messages,
      :class_name => 'MB::Message',
      :foreign_key => 'categoryid'

    # URL path to this Category. Works on Liferay 5.1.1.
    # Parameters:
    #  - pl          only check public or private layouts? defaults to both. ( nil | :public | :private )
    def path(pl=nil)
      layouts = self.group.select_layouts_with('message_boards',pl)
      return nil unless layouts.any?
      '%s/-/message_boards/category/%i' % [layouts.first.path, self.id]
    end

  end
end