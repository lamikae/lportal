module Tag
  # Represents the table tagsasset
  class Asset < ActiveRecord::Base
    set_table_name       :tagsasset
    set_primary_key      :assetid

    # com.liferay.portlet.tags.model.TagsAsset
    def liferay_class
      'com.liferay.portlet.tags.model.TagsAsset'
    end

# COPY tagsasset (assetid, groupid, companyid, userid, username, createdate, modifieddate, classnameid, classpk, startdate, enddate, publishdate, expirationdate, mimetype, title, description, summary, url, height, width, priority, viewcount) FROM stdin;
# +10311	10166	10109	10129	Test Test	2009-01-17 08:07:12.039	2009-01-17 08:07:12.039	10071	10308	\N	\N	\N	\N	text/html	New thread				0	0	0	0


    def initialize(params)
      super(params)
      self.createdate     ||= Time.now
      self.modifieddate   ||= Time.now
      self.startdate      ||= nil
      self.enddate        ||= nil
      self.publishdate    ||= nil
      self.expirationdate ||= nil
      self.mimetype       ||= 'text/html'
      self.title          ||= ''
      self.description    ||= ''
      self.summary        ||= ''
      self.url            ||= ''
      self.height         ||= 0
      self.width          ||= 0
      self.priority       ||= 0
      self.viewcount      ||= 0
      self.save
    end

    belongs_to :company,
      :foreign_key => 'companyid'

    # association to user
    belongs_to :user,
      :foreign_key => 'userid'
    alias :owner :user

    # association to groups (communities)
    belongs_to :group,
      :foreign_key => 'groupid'
    alias :community :group

    # association to tags
    has_and_belongs_to_many  :tags,
      :class_name              => 'Tag::Entry',
      :join_table              => 'tagsassets_tagsentries',
      :foreign_key             => 'assetid',
      :association_foreign_key => 'entryid'

    def self.resource_types
      [
        BlogPost,
        Wiki::Page,
        MB::Message,
        Journal::Article,
        DlFile,
        IG::Image,
        Bookmark::Entry,
#         Group,
#         DlFolder
      ]
    end

    # Content can be of several different types.
    # Finding Wiki::Page s and Journal::Article s is a bit tricky..
    def resource
      resource_id = self.classpk
      #logger.debug "Looking up resource #{resource_id}"

      _class = Classname.model(Classname.find(self.classnameid).value)
      if _class
        if _class==Wiki::Page
          Wiki::Page.find(:first,
            :conditions => "resourceprimkey=#{resource_id}", :order => "version DESC")

        elsif _class==Journal::Article
          Journal::Article.find(:first,
            :conditions => "resourceprimkey=#{resource_id}", :order => "version DESC")

        else
          _class.find resource_id
        end

      else
        logger.warn "Resource #{resource_id} of asset #{self.id} was left unresolved"
        return nil
      end
    end

    # label (logic to fetch non-empty title)
    def label
      return self.title if self.title.any?

      # fallback to the name of the resource
      if self.resource.respond_to?(:name) && self.resource.name.any?
        return self.resource.name
      else
        STDERR.puts 'Asset %i has no title' % self.id
        return ''
      end
    end

  end
end
