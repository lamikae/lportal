class DlFile < ActiveRecord::Base

  belongs_to :folder,
    :class_name  => 'DlFolder',
    :foreign_key => DlFolder.primary_key

  belongs_to :company, :foreign_key => Company.primary_key

  belongs_to :user,    :foreign_key => User.primary_key

  has_one :asset,
    :class_name  => 'Tag::Asset',
    :foreign_key => 'classPK'

  # URL path to download this Document Library File
  def path
    '/c/document_library/get_file?folderId=%i&name=%s' % [self.folderid, self.name]
  end

end
