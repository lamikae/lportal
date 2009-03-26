class Organization < ActiveRecord::Base
  set_table_name       :Organization_
  set_primary_key      :organizationId

  # com.liferay.portal.model.Organization
  def liferay_class
    'com.liferay.portal.model.Organization'
  end

  belongs_to :company,
    :foreign_key => 'companyid'

  # association to users
  has_and_belongs_to_many  :users,
                           :join_table              => 'users_orgs',
                           :foreign_key             => 'organizationid',
                           :association_foreign_key => 'userid'
  alias :members :users

  belongs_to :parent,
    :class_name  => 'Organization',
    :foreign_key => 'parentorganizationid'

  # Organization's own group
  has_one :group,
    :class_name  => 'Group',
    :foreign_key => 'classpk'

  def hive
    self.group
  end

  belongs_to :status,
    :class_name => 'ListType',
    :foreign_key => :statusid

end
