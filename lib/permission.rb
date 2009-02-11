class Permission < ActiveRecord::Base
  set_table_name       :permission_
  set_primary_key      :permissionid

  belongs_to :company,
    :foreign_key => 'companyid'

  belongs_to :resource,
    :foreign_key => 'resourceid'

  # association to users
  has_and_belongs_to_many  :users,
                           :join_table              => 'users_permissions',
                           :foreign_key             => 'permissionid',
                           :association_foreign_key => 'userid'

  has_and_belongs_to_many :roles,
    :join_table              => 'roles_permissions',
    :foreign_key             => 'permissionid',
    :association_foreign_key => 'roleid'

  has_and_belongs_to_many :groups,
    :join_table              => 'groups_permissions',
    :foreign_key             => 'permissionid',
    :association_foreign_key => 'groupid'

  def holders
    self.users + self.roles + self.groups
  end


end
