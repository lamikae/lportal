class Company < ActiveRecord::Base
  set_table_name       :Company
  set_primary_key      :companyId

  # com.liferay.portal.model.Company
  def self.liferay_class
    'com.liferay.portal.model.Company'
  end
  def liferay_class # :nodoc:
    self.class.liferay_class
  end

  has_one :account,
    :foreign_key => self.primary_key

  has_one :address,
    :foreign_key => self.primary_key

  has_many :contacts,
    :foreign_key => self.primary_key

  has_many :users,
    :foreign_key => self.primary_key

  has_many :groups,
    :foreign_key => self.primary_key

  has_many :organizations,
    :foreign_key => self.primary_key

  has_many :layoutsets,
    :class_name  => 'Web::LayoutSet',
    :foreign_key => self.primary_key

  has_one :resource,
    :foreign_key => 'primkey'

  # A list of Users who have the Role 'Administrator'. Scope is not checked!
  # Returns a list of Users, or nil if there is no Administrator Role in this Company.
  def administrators
    adminrole = Role.find(:first, :conditions => "#{self.class.primary_key}=#{self.id} AND name='Administrator'")
    adminrole ?
      adminrole.users.select{|u| u.company==self} : nil
  end
  alias :admins :administrators

  # The default user for this Company.
  def guest
    User.find(:first, :conditions => "#{self.class.primary_key}=#{self.id} AND defaultuser = true" )
  end

  # Oddly enough, guest user's does not have a personal group relation in 5.1.1 nor 5.2.1
  def guest_group
    Group.find(:first, :conditions => "#{self.class.primary_key}=#{self.id} AND name='Guest'")
  end

  # 0 = personal user groups
  def personal_groups
    Group.find_personal self.id
  end

  # 1 = public, guest can see
  def public_groups
    Group.find_public self.id
  end

  # 2 = user-created open communities
  def open_groups
    Group.find_open self.id
  end

  # 3 = private, also contains admins
  def private_groups
    Group.find_private self.id
  end

end
