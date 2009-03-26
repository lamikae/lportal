class Role < ActiveRecord::Base
  set_table_name       :Role_
  set_primary_key      :roleId

  # com.liferay.portal.model.Role
  def self.liferay_class
    'com.liferay.portal.model.Role'
  end
  def liferay_class
    self.class.liferay_class
  end

  acts_as_resourceful

  #validates_uniqueness_of :name, :scope => 'companyid'

  # Actions for Permissions.
  def self.actions
    %w{
      ASSIGN_MEMBERS
      DEFINE_PERMISSIONS
      DELETE
      MANAGE_ANNOUNCEMENTS
      PERMISSIONS
      UPDATE
      VIEW
    }
  end

  # Creates a new role.
  #
  # This process is engineered by creating a new role with Liferay's (v. 5.1.1) tools and
  # inspecting the database dump diffs.
  #
  # Mandatory parameters:
  #  - companyid
  #  - name
  def initialize(params)
    raise 'No companyid given' unless (params[:companyid] or params[:company])
    raise 'No name given' unless params[:name]

    super(params)

    # COPY role_ (roleid, companyid, classnameid, classpk, name, description, type_) FROM stdin;
    # +10151	10109	0	0	Regular role	This role is a test	1

    self.classnameid ||= 0
    self.classpk     ||= 0
    self.description ||= ''
    # Type: 1 = regular, 2 = community, 3 = organization
    self.type_       ||= 1

    self.save

    # Resource with code scope 1 is primkey'd to company.
    # Resource with code scope 4 is primkey'd to this role.

    # These are created regardless of what type_ is.

    # COPY resourcecode (codeid, companyid, name, scope) FROM stdin;
    # +29	10109	com.liferay.portal.model.Role	1
    # +30	10109	com.liferay.portal.model.Role	4

    [1,4].each do |scope|
      rc = self.resource_code(scope)
      unless rc
        ResourceCode.create(
          Company.primary_key => self.companyid,
          :name      => self.liferay_class,
          :scope     => scope
        )
      end
    end

    # COPY resource_ (resourceid, codeid, primkey) FROM stdin;
    # +33	29	10109
    # +34	30	10151

    self.get_resource(:scope => 1)
    r = self.get_resource(:scope => 4)

    # Permissions (given to administrators)

    #  COPY permission_ (permissionid, companyid, actionid, resourceid) FROM stdin;
    # +70     10109   ASSIGN_MEMBERS  34
    # +71     10109   DEFINE_PERMISSIONS      34
    # +72     10109   DELETE  34
    # +73     10109   MANAGE_ANNOUNCEMENTS    34
    # +74     10109   PERMISSIONS     34
    # +75     10109   UPDATE  34
    # +76     10109   VIEW    34

    # COPY users_permissions (userid, permissionid) FROM stdin;
    # +10129	70
    # +10129	71
    # +10129	72
    # +10129	73
    # +10129	74
    # +10129	75
    # +10129	76

    self.class.actions.each do |actionid|
      p = Permission.get(
        :companyid  => self.companyid,
        :actionid   => actionid,
        :resourceid => r.id
      )
      self.company.administrators.each do |user|
        user.permissions << p
      end
    end
  end

  def destroy_without_callbacks
    unless new_record?
      rc = self.resource_code(4)
      if rc
        r = Resource.find(:first, :conditions => "codeid=#{rc.id} AND primkey='#{self.id}'")
        if r
          self.class.actions.each do |actionid|
            p = Permission.find(:first,
              :conditions => "#{Company.primary_key}=#{self.companyid} AND actionid='#{actionid}' AND resourceid=#{r.id}")
            next unless p
            p.users.each do |user|
              user.permissions.delete(p)
            end
            p.groups.each do |group|
              group.permissions.delete(p)
            end
            p.destroy
          end
          r.destroy
        end
        rc.destroy
      end

      self.users.each do |user|
        user.roles.delete(self)
      end

      self.groups.each do |group|
        group.roles.delete(self)
      end

      super

    end
    freeze
  end

  belongs_to :company,
    :foreign_key => Company.primary_key

  has_and_belongs_to_many :permissions,
    :join_table              => "Roles_Permissions",
    :foreign_key             => "roleId",
    :association_foreign_key => "permissionId"

  # association to users
  has_and_belongs_to_many  :users,
                           :join_table              => "Users_Roles",
                           :foreign_key             => "roleId",
                           :association_foreign_key => "userId"

  # association to users
  has_and_belongs_to_many  :groups,
                           :join_table              => "Groups_Roles",
                           :foreign_key             => "roleId",
                           :association_foreign_key => "groupId"

end
