module Bookmark
  class Folder < ActiveRecord::Base
    set_table_name       :bookmarksfolder
    set_primary_key      :folderid

    # com.liferay.portlet.bookmarks.model.BookmarksFolder
    def liferay_class
      'com.liferay.portlet.bookmarks.model.BookmarksFolder'
    end

    belongs_to :company,
      :foreign_key => 'companyid'

    belongs_to :user,
      :foreign_key => 'userid'

  end
end