class DlFolder < ActiveRecord::Base
  set_table_name       :dlfolder
  set_primary_key      :folderid

  # com.liferay.portlet.documentlibrary.model.DLFolder
  def liferay_class
    'com.liferay.portlet.documentlibrary.model.DLFolder'
  end

  has_many :files,
    :class_name  => 'DlFile',
    :foreign_key => 'folderid'

  belongs_to :company,
    :foreign_key => 'companyid'

  belongs_to :user,
    :foreign_key => 'userid'
  alias :owner :user

  belongs_to :group,
    :foreign_key => 'groupid'
  alias :community :group

#   has_one :asset,
#     :class_name  => 'Tag::Asset',
#     :foreign_key => 'classpk'

end
