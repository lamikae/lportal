module MB
  class Message < ActiveRecord::Base
    set_table_name       :mbmessage
    set_primary_key      :messageid

#     validates_presence_of :user, :category, :subject, :body


    # com.liferay.portlet.messageboards.model.MBMessage
    def liferay_class
      'com.liferay.portlet.messageboards.model.MBMessage'
    end

    # Actions for Permissions.
    def self.actions
      %w{
        DELETE
        PERMISSIONS
        SUBSCRIBE
        UPDATE
        VIEW
      }
    end

    #  - user
    #  - category or parent message
    #  - body
    def initialize(params)
      raise 'No user' unless params[:user] or params[:userid]
      unless ((params[:category] or params[:categoryid]) || (params[:parent] or params[:parentmessageid]))
        raise 'No category or parentmessage'
      end
      raise 'No body' unless params[:body]
      super(params)

      # COPY mbmessage (uuid_, messageid, companyid, userid, username, createdate, modifieddate, categoryid, threadid, parentmessageid, subject, body, attachments, anonymous) FROM stdin;
      # +66089117-ddb5-4577-ba9b-76479a273727	10308	10109	10129	Test Test	2009-01-17 08:07:11.947	2009-01-17 08:07:11.947	10307	10309	0	New thread	This is a test, using rich editor.	f	f

      unless self.uuid_
        require 'rubygems'
        require 'uuidtools'
        self.uuid_ = UUID.random_create.to_s
      end

      self.category ||= self.parent.category
      category = self.category

      self.companyid ||= category.companyid

      # always require User
      #unless self.userid
      #  self.userid = 0
      #  self.anonymous = true
      #else
        self.anonymous = false
      #end

      self.subject         ||= ''
      self.username        ||= ''
      self.createdate      = Time.now
      self.modifieddate    = Time.now
      self.parentmessageid ||= 0
      self.attachments     ||= false
      self.save


      # COPY mbcategory (uuid_, categoryid, groupid, companyid, userid, username, createdate, modifieddate, parentcategoryid, name, description, lastpostdate) FROM stdin;
      # -fda18eef-3992-419e-a373-6e2f01a8b6a9	10307	10166	10109	10129	Test Test	2009-01-17 08:06:00.359	2009-01-17 08:06:00.359	0	Teppo Testaaja	message board for user Teppo	\N
      # +fda18eef-3992-419e-a373-6e2f01a8b6a9	10307	10166	10109	10129	Test Test	2009-01-17 08:06:00.359	2009-01-17 08:06:00.359	0	Teppo Testaaja	message board for user Teppo	2009-01-17 08:07:11.947

      category.lastpostdate = Time.now
      category.save


      # COPY mbthread (threadid, categoryid, rootmessageid, messagecount, viewcount, lastpostbyuserid, lastpostdate, priority) FROM stdin;
      # +10309	10307	10308	1	1	10129	2009-01-17 08:07:11.947	0

      thread = MB::Thread.find(:first,
        :conditions => "categoryid=#{category.id} AND rootmessageid=#{self.find_thread_root.id}")
      unless thread
        thread = MB::Thread.create(
          :category => category,
          :rootmessage => self,
          :messagecount => 0,
          :viewcount => 0
        )
      end
      thread.messagecount += 1
      thread.lastpostbyuserid = self.user.id
      thread.lastpostdate = Time.now
      thread.save
      self.thread = thread


      # COPY mbmessageflag (messageflagid, userid, messageid, flag) FROM stdin;
      # +10313	10129	10308	1

      unless self.flag # wtf?
        self.flag = MB::MessageFlag.create(
          :user    => self.user,
          :message => self,
          :flag    => 1
        )
      end


      # COPY mbstatsuser (statsuserid, groupid, userid, messagecount, lastpostdate) FROM stdin;
      # +10310	10166	10129	1	2009-01-17 08:07:12.014

      stats = MB::StatsUser.find(:first, :conditions => "groupid=#{category.groupid} AND userid=#{self.user.id}")
      unless stats
        stats = MB::StatsUser.create(
          :groupid => category.groupid,
          :user => self.user,
          :messagecount => 0
        )
      end
      stats.messagecount += 1
      stats.lastpostdate = Time.now
      stats.save


      # COPY ratingsstats (statsid, classnameid, classpk, totalentries, totalscore, averagescore) FROM stdin;
      # +10312	10071	10308	0	0	0

      classnameid = Classname.find_by_value(self.liferay_class).id

      unless RatingsStats.find(:first,
        :conditions => "classnameid=#{classnameid} AND classpk=#{self.id}")
        RatingsStats.create(
          :classnameid => classnameid,
          :classpk => self.id
        )
      end


      # COPY socialactivity (activityid, groupid, companyid, userid, createdate, mirroractivityid, classnameid, classpk, type_, extradata, receiveruserid) FROM stdin;
      # +1	10166	10109	10129	2009-01-17 08:07:12.024	0	10071	10308	1		0

      unless SocialActivity.find(:first,
        :conditions => "userid=#{self.user.id} AND classnameid=#{classnameid} AND classpk=#{self.id}")
        SocialActivity.create(
          :group       => category.group,
          :company     => self.company,
          :user        => self.user,
          :classnameid => classnameid,
          :classpk     => self.id
        )
      end


      # COPY tagsasset (assetid, groupid, companyid, userid, username, createdate, modifieddate, classnameid, classpk, startdate, enddate, publishdate, expirationdate, mimetype, title, description, summary, url, height, width, priority, viewcount) FROM stdin;
      # +10311	10166	10109	10129	Test Test	2009-01-17 08:07:12.039	2009-01-17 08:07:12.039	10071	10308	\N	\N	\N	\N	text/html	New thread				0	0	0	0

      unless Tag::Asset.find(:first,
        :conditions => "userid=#{self.user.id} AND classnameid=#{classnameid} AND classpk=#{self.id}")
        Tag::Asset.create(
          :group       => category.group,
          :company     => self.company,
          :user        => self.user,
          :classnameid => classnameid,
          :classpk     => self.id,
          :title       => 'New thread'
        )
      end


      # ResourceCode with scope 1 => Resource for Company
      # ResourceCode with scope 2 => Resource for this Group and Guest's Group
      # ResourceCode with scope 4 => Resource for self

      # COPY resourcecode (codeid, companyid, name, scope) FROM stdin;
      # +107	10109	com.liferay.portlet.messageboards.model.MBMessage	1
      # +108	10109	com.liferay.portlet.messageboards.model.MBMessage	2
      # +109	10109	com.liferay.portlet.messageboards.model.MBMessage	4

      # COPY resource_ (resourceid, codeid, primkey) FROM stdin;
      # +214	107	10109
      # +215	108	10124 << this is Guest's group
      # +216	108	10166
      # +217	109	10308

      # only create resources with scope 1,2 for rootmessages
      if self.is_root?
        find_resource(:scope => 1)
        find_resource(:scope => 2)
      end

      # Create a resource with scope=4
      resource = find_resource(:scope => 4)


      # COPY permission_ (permissionid, companyid, actionid, resourceid) FROM stdin;
      # +323	10109	DELETE	217
      # +324	10109	PERMISSIONS	217
      # +325	10109	SUBSCRIBE	217
      # +326	10109	UPDATE	217
      # +327	10109	VIEW	217

      # COPY users_permissions (userid, permissionid) FROM stdin;
      # +10129	323
      # +10129	324
      # +10129	325
      # +10129	326
      # +10129	327

      self.class.actions.each do |actionid|
        permission = Permission.get({
          :companyid  => self.companyid,
          :actionid   => actionid,
          :resourceid => resource.id
        })
        self.user.permissions << permission
      end

      self.save
    end

    belongs_to :company,
      :foreign_key => 'companyid'

    belongs_to :user,
      :foreign_key => 'userid'
    alias :writer :user
    alias :owner  :user

    belongs_to :category,
      :class_name => 'MB::Category',
      :foreign_key => 'categoryid'

    belongs_to :thread,
      :class_name => 'MB::Thread',
      :foreign_key => 'threadid'

    has_one :flag,
      :class_name => 'MB::MessageFlag',
      :foreign_key => 'messageid'


    has_one :asset,
      :class_name  => 'Tag::Asset',
      :foreign_key => 'classpk'


    # Parent message
    def parent
      self.is_root? ? nil : MB::Message.find(self.parentmessageid)
    end
    def parent=(msg)
      raise 'Parent must be MB::Message' unless msg.is_a?(MB::Message)
      self.parentmessageid = msg.id
    end

    # First in thread?
    def is_root?
      self.parentmessageid == 0
    end

    # Finds the first in the thread recursively.
    #
    # Since initialize() uses this method to find the root message before the thread is known,
    # MB::Thread methods cannot be used. Otherwise, self.thread.rootmessage would be faster.
    # Using while (or until) loops may lead to never-ending loops if the database contains awkward data
    # (actual root message pointing to another message etc)
    def find_thread_root
      msg = self
      until (msg.is_root?) do
        msg = msg.parent
      end
      return msg
    end

    def has_attachements?
      self.attachements
    end

    def is_anonymous?
      self.anonymous
    end

    # ResourceCode associated to this instance (and scope)
    def resource_code(scope=4)
      ResourceCode.get({
        :companyid => self.companyid,
        :name => self.liferay_class,
        :scope => scope
      })
    end

    # resource by codeid
    def resource(rc)
      case rc.scope
      when 1
        primkey = self.companyid
      when 2
        primkey = self.category.groupid
      when 4
        primkey = self.id
      else
        raise 'unknown scope'
      end
      Resource.get({
        :codeid  => rc.codeid,
        :primkey => primkey
      })
    end

    # When creating new instances, it is common to find a resource code, and a resource that matches the code.
    # If they cannot be found from the database, they are created.
    # This method takes care of all that.
    def find_resource(args)
      rc = self.resource_code(args[:scope])
      self.resource(rc)
    end

  end
end