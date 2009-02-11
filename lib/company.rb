class Company < ActiveRecord::Base
  set_table_name       :company
  set_primary_key      :companyid

  has_one :account,
    :foreign_key => 'companyid'

  has_one :address,
    :foreign_key => 'companyid'

  has_many :organizations,
    :foreign_key => 'companyid'

  has_many :contacts,
    :foreign_key => 'companyid'

  has_many :users,
    :foreign_key => 'companyid'

  has_many :groups,
    :foreign_key => 'companyid'

  has_many :layoutsets,
    :class_name  => 'Web::LayoutSet',
    :foreign_key => 'companyid'

  has_one :resource,
    :foreign_key => 'primkey'

  # com.liferay.portal.model.Company
  def liferay_class
    'com.liferay.portal.model.Company'
  end

  # A list of Users who have the Role 'Administrator'. Scope is not checked!
  def administrators
    adminrole = Role.find(:first, :conditions => "companyid=#{self.id} AND name='Administrator'")
    return self.users.select{|u| u.roles.include?(adminrole) }
  end
  alias :admins :administrators

  # The default user for this Company.
  def guest
    User.find(:first, :conditions => "companyid=#{self.id} AND defaultuser = true" )
  end

#   has_one :frontpage,
#     :class_name  => "Web::LayoutSet",
#     :foreign_key => "companyid",
#     :conditions  => "privatelayout=false AND virtualhost='#{@virtualhost}'"



end
