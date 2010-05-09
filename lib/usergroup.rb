# encoding: utf-8

class Usergroup < ActiveRecord::Base

  belongs_to :company,
    :foreign_key => Company.primary_key

  # association to direct groups
  has_and_belongs_to_many  :groups,
    :join_table              => 'groups_usergroups',
    :foreign_key             => 'usergroupid',
    :association_foreign_key => 'groupid'

  has_one :parent,
    :class_name  => 'Usergroup',
    :foreign_key => 'parentusergroupid'

end
