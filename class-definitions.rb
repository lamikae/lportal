# --
# The classes have cross-references, so each has to be defined before the actual models are loaded.
# Since adding support for different database schemas, the primary keys also need to be defined here.
# The models that have the definitions have more or less complete support for MySQL.
# PostgreSQL should *always* work.
# ++

# com.liferay.portal.model.Account
class Account < ActiveRecord::Base
  def self.liferay_class; 'com.liferay.portal.model.Account'; end
  set_table_name       :Account_
  set_primary_key      :accountId
end

# com.liferay.portal.model.Address
class Address < ActiveRecord::Base
  def self.liferay_class; 'com.liferay.portal.model.Address'; end
  set_table_name       :Address
  set_primary_key      :addressId
end
# ActiveRecord::StatementInvalid: Mysql::Error: Table 'lportal_test.announcementsentry' doesn't exist: DELETE FROM `announcementsentry`

# com.liferay.portlet.blogs.model.BlogsEntry
class BlogPost < ActiveRecord::Base
  def self.liferay_class; 'com.liferay.portal.model.BlogsEntry'; end
  set_table_name       :BlogsEntry
  set_primary_key      :entryId
end
# ActiveRecord::StatementInvalid: Mysql::Error: Table 'lportal_test.calevent' doesn't exist: DELETE FROM `calevent`

# com.liferay.portal.model.Company
class Company < ActiveRecord::Base
  def self.liferay_class; 'com.liferay.portal.model.Company'; end
  set_table_name       :Company
  set_primary_key      :companyId
end

# com.liferay.portal.model.Contact
class Contact < ActiveRecord::Base
  def self.liferay_class; 'com.liferay.portal.model.Contact'; end
  set_table_name       :Contact_
  set_primary_key      :contactId
end

# Counter for Hibernate
class Counter < ActiveRecord::Base
  set_table_name       :Counter
  set_primary_key      :name
end

# com.liferay.portlet.documentlibrary.model.DLFileEntry
class DlFile < ActiveRecord::Base
  def self.liferay_class; 'com.liferay.portlet.documentlibrary.model.DLFileEntry'; end
  set_table_name       :DLFileEntry
  set_primary_key      :fileEntryId
end

# com.liferay.portlet.documentlibrary.model.DLFolder
class DlFolder < ActiveRecord::Base
  def self.liferay_class; 'com.liferay.portlet.documentlibrary.model.DLFolder'; end
  set_table_name       :DLFolder
  set_primary_key      :folderId
end

# com.liferay.portal.model.EmailAddress
class Emailaddress < ActiveRecord::Base
  def self.liferay_class; 'com.liferay.portal.model.EmailAddress'; end
  set_table_name       :EmailAddress
  set_primary_key      :emailAddressId
end

# com.liferay.portal.model.Group
class Group < ActiveRecord::Base
  def self.liferay_class; 'com.liferay.portal.model.Group'; end
  set_table_name       :Group_
  set_primary_key      :groupId
end

# com.liferay.portal.model.Image
class Image < ActiveRecord::Base
  def self.liferay_class; 'com.liferay.portal.model.Image'; end
  set_table_name       :Image
  set_primary_key      :imageId
end

# com.liferay.portal.model.Organization
class Organization < ActiveRecord::Base
  def self.liferay_class; 'com.liferay.portal.model.Organization'; end
  set_table_name       :Organization_
  set_primary_key      :organizationId
end

# com.liferay.portal.model.Permission
class Permission < ActiveRecord::Base
  def self.liferay_class; 'com.liferay.portal.model.Permission'; end
  set_table_name       :Permission_
  set_primary_key      :permissionId
end

# com.liferay.portal.model.Phone
class Phone < ActiveRecord::Base
  def self.liferay_class; 'com.liferay.portal.model.Phone'; end
  set_table_name       :Phone
  set_primary_key      :phoneId
end

# Version of the database schema.
class Release < ActiveRecord::Base
  set_table_name       :Release_
  set_primary_key      :releaseId
end

# com.liferay.portal.model.ResourceCode
class ResourceCode < ActiveRecord::Base
  def self.liferay_class; 'com.liferay.portal.model.ResourceCode'; end
  set_table_name       :ResourceCode
  set_primary_key      :codeId
end

# com.liferay.portal.model.Resource
class Resource < ActiveRecord::Base
  def self.liferay_class; 'com.liferay.portal.model.Resource'; end
  set_table_name       :Resource_
  set_primary_key      :resourceId
end

# com.liferay.portal.model.Role
class Role < ActiveRecord::Base
  def self.liferay_class; 'com.liferay.portal.model.Role'; end
  set_table_name       :Role_
  set_primary_key      :roleId
end

# com.liferay.portal.model.UserGroup
class Usergroup < ActiveRecord::Base
  def self.liferay_class; 'com.liferay.portal.model.UserGroup'; end
  set_table_name       :UserGroup
  set_primary_key      :userGroupId
end

# com.liferay.portal.model.User
class User < ActiveRecord::Base
  def self.liferay_class; 'com.liferay.portal.model.User'; end
  set_table_name       :User_
  set_primary_key      :userId
end

# Image Gallery
module IG
  # com.liferay.portlet.imagegallery.model.IGImage
  class Image < ActiveRecord::Base
  def self.liferay_class; 'com.liferay.portlet.imagegallery.model.IGImage'; end
    set_table_name       :IGImage
    set_primary_key      :imageId
  end

  # com.liferay.portlet.imagegallery.model.IGFolder
  class Folder < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portlet.imagegallery.model.IGFolder'; end
    set_table_name       :IGFolder
    set_primary_key      :folderId
  end
end

module Bookmark
  # com.liferay.portlet.bookmarks.model.BookmarksEntry
  class Entry < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portlet.bookmarks.model.BookmarksEntry'; end
    set_table_name       :BookmarksEntry
    set_primary_key      :entryId
  end

  # com.liferay.portlet.bookmarks.model.BookmarksFolder
  class Folder < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portlet.bookmarks.model.BookmarksFolder'; end
    set_table_name       :BookmarksFolder
    set_primary_key      :folderId
  end
end

module Journal
  # com.liferay.portlet.journal.model.JournalArticle
  class Article < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portlet.journal.model.JournalArticle'; end
    set_table_name       :JournalArticle
    set_primary_key      :id_
  end

  # com.liferay.portlet.journal.model.JournalArticleResource
  class ArticleResource < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portlet.journal.model.JournalArticleResource'; end
    set_table_name       :JournalArticleResource
    set_primary_key      :resourcePrimKey
  end
end

# Message Boards
module MB
  # com.liferay.portlet.messageboards.model.MBThread
  class Thread < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portlet.messageboards.model.MBThread'; end
    set_table_name       :MBThread
    set_primary_key      :threadId
  end

  # com.liferay.portlet.messageboards.model.MBMessage
  class Message < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portlet.messageboards.model.MBMessage'; end
    set_table_name       :MBMessage
    set_primary_key      :messageId
  end

  # com.liferay.portlet.messageboards.model.MBCategory
  class Category < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portlet.messageboards.model.MBCategory'; end
    set_table_name       :MBCategory
    set_primary_key      :categoryId
  end

  # com.liferay.portlet.messageboards.model.MBDiscussion
  class Discussion < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portlet.messageboards.model.MBDiscussion'; end
    set_table_name       :MBDiscussion
    set_primary_key      :discussionId
  end
end

module Tag
  # com.liferay.portlet.tags.model.TagsAsset
  class Asset < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portlet.tags.model.TagsAsset'; end
    set_table_name       :TagsAsset
    set_primary_key      :assetId
  end

  # com.liferay.portlet.tags.model.TagsEntry
  class Entry < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portlet.tags.model.TagsEntry'; end
    set_table_name       :TagsEntry
    set_primary_key      :entryId
  end

  # com.liferay.portlet.tags.model.TagsProperty
  class Property < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portlet.tags.model.TagsProperty'; end
    set_table_name       :TagsProperty
    set_primary_key      :propertyId
  end
end

module Web

  # com.liferay.portal.model.LayoutSet
  class LayoutSet < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portal.model.LayoutSet'; end
    set_table_name       :LayoutSet
    set_primary_key      :layoutSetId
  end

  # com.liferay.portal.model.Layout
  class Layout < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portal.model.Layout'; end
    set_table_name       :Layout
    set_primary_key      :plid
  end

  # com.liferay.portal.model.Portlet
  class Portlet < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portal.model.Portlet'; end
    set_table_name       :Portlet
    set_primary_key      :id_
  end

  # com.liferay.portal.model.PortletPreferences
  class PortletPreferences < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portal.model.PortletPreferences'; end
    set_table_name       :PortletPreferences
    set_primary_key      :portletPreferencesId
  end

  # This table is not in the original lportal database.
  # This is created by a ActiveRecord migration and contains metadata about portlets.
  class PortletProperties < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portal.model.LayoutSet'; end
    set_table_name       :portletproperties
  end
end

module Wiki
  # com.liferay.portlet.wiki.model.WikiNode
  class Node < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portlet.wiki.model.WikiNode'; end
    set_table_name       :WikiNode
    set_primary_key      :nodeId
  end

  # com.liferay.portlet.wiki.model.WikiPage
  class Page < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portlet.wiki.model.WikiPage'; end
    set_table_name       :WikiPage
    set_primary_key      :pageId
  end

  # com.liferay.portlet.wiki.model.WikiPageResource
  class PageResource < ActiveRecord::Base
    def self.liferay_class; 'com.liferay.portlet.wiki.model.WikiPageResource'; end
    set_table_name       :WikiPageResource
    set_primary_key      :resourcePrimKey
  end
end
