class Usergroup < ActiveRecord::Base
  set_table_name       :usergroup
  set_primary_key      :usergroupid

  # com.liferay.portal.model.UserGroup
  def liferay_class
    'com.liferay.portal.model.UserGroup'
  end

  belongs_to :company,
    :foreign_key => 'companyid'

  # association to direct groups
  has_and_belongs_to_many  :groups,
    :join_table              => 'groups_usergroups',
    :foreign_key             => 'usergroupid',
    :association_foreign_key => 'groupid'

  has_one :parent,
    :class_name  => 'Usergroup',
    :foreign_key => 'parentusergroupid'

end
