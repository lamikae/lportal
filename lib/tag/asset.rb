module Tag
  class Asset < ActiveRecord::Base

    def initialize(params)
      super(params)

      # COPY tagsasset (assetid, groupid, companyid, userid, username, createdate, modifieddate, classnameid, classpk, startdate, enddate, publishdate, expirationdate, mimetype, title, description, summary, url, height, width, priority, viewcount) FROM stdin;
      # +10311    10166   10109   10129   Test Test   2009-01-17 08:07:12.039 2009-01-17 08:07:12.039 10071   10308   \N  \N  \N  \N  text/html   New thread              0   0   0   0

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
      :foreign_key => Company.primary_key

    # association to user
    belongs_to :user,
      :foreign_key => User.primary_key
    alias :owner :user

    # association to groups (communities)
    belongs_to :group,
      :foreign_key => Group.primary_key
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
        logger.warn 'Asset %i has no title' % self.id
        return ''
      end
    end

    # Presents the Asset resource in a portlet that is capable of viewing tagged content.
    # This depends on the version of Liferay. See Group#asset_viewer_portlet.
    #
    # This method requires that the Asset belongs to a Group, or that the portletpreferences is given.
    #
    # Params:
    #  - content_id           the id of the resource (not always self.resource.id)
    #  - portletpreferences   defaults to the asset_viewer_portlet of the Asset's Group.
    def path(portletpreferences=self.group.asset_viewer_portlet)
      if self.group==0
        logger.warn 'No asset path will be given for assets with groupid 0'
        return ''
      elsif !portletpreferences.is_a?(Web::PortletPreferences)
        logger.error 'No portletpreferences for asset display given'
        return ''
      end
      logger.debug portletpreferences.inspect
      # path is defined in Lportal::Portlets
      path = portletpreferences.path(:asset => self)
      logger.debug path
      return path
    end

  end
end
