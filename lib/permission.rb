class Permission < ActiveRecord::Base

  belongs_to :company,
    :foreign_key => Company.primary_key

  belongs_to :resource,
    :foreign_key => Resource.primary_key

  # association to users
  has_and_belongs_to_many  :users,
                           :join_table              => 'Users_Permissions',
                           :foreign_key             => self.primary_key,
                           :association_foreign_key => User.primary_key

  has_and_belongs_to_many :roles,
    :join_table              => 'Roles_Permissions',
    :foreign_key             => self.primary_key,
    :association_foreign_key => Role.primary_key

  has_and_belongs_to_many :groups,
    :join_table              => 'Groups_Permissions',
    :foreign_key             => self.primary_key,
    :association_foreign_key => Group.primary_key

  # finds or creates
  def self.get(args)
    conditions = []
    args.each_pair{ |k,v|
      conditions << (k==:actionid ?
        ("%s='%s'" % [k,v]) : ("%s=%s" % [k,v]))
    }
    #logger.debug conditions.inspect
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
