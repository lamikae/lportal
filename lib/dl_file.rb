class DlFile < ActiveRecord::Base
  set_table_name       :dlfileentry
  set_primary_key      :fileentryid

  # com.liferay.portlet.documentlibrary.model.DLFileEntry
  def liferay_class
    'com.liferay.portlet.documentlibrary.model.DLFileEntry'
  end

  belongs_to :folder,
    :class_name  => 'DlFolder',
    :foreign_key => 'folderid'

  belongs_to :company,
    :foreign_key => 'companyid'

  belongs_to :user,
    :foreign_key => 'userid'
  alias :owner :user

  has_one :asset,
    :class_name  => 'Tag::Asset',
    :foreign_key => 'classpk'


  # URL path to download this Document Library File
  def path
    '/c/document_library/get_file?folderId=%i&name=%s' % [self.folderid, self.name]
  end

end
