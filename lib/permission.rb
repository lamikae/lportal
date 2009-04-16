class Permission < ActiveRecord::Base

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

  # finds or creates
  def self.get(args)
    conditions = []
    args.each_pair{ |k,v|
      conditions << (k==:actionid ?
        ("%s='%s'" % [k,v]) : ("%s=%s" % [k,v]))
    }
    #puts conditions.inspect
    p = Permission.find(:first, :conditions => conditions.join(' AND '))
    unless p
      logger.debug 'creating new Permission'
      p = self.create(args)
    end
    return p
  end

  def holders
    self.users + self.roles + self.groups
  end

end
