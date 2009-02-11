module Bookmark
  class Entry < ActiveRecord::Base
    set_table_name       :bookmarksentry
    set_primary_key      :entryid

    # com.liferay.portlet.bookmarks.model.BookmarksEntry
    def liferay_class
      'com.liferay.portlet.bookmarks.model.BookmarksEntry'
    end

    belongs_to :company,
      :foreign_key => 'companyid'

    belongs_to :user,
      :foreign_key => 'userid'

    belongs_to :folder,
      :class_name => 'Bookmark::Folder',
      :foreign_key => 'folderid'

    has_one :asset,
      :class_name  => 'Tag::Asset',
      :foreign_key => 'classpk'

  end
end
