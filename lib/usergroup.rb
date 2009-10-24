class Usergroup < ActiveRecord::Base

  belongs_to :company,
    :foreign_key => Company.primary_key

  # association to direct groups
  has_and_belongs_to_many  :groups,
    :join_table              => 'Groups_UserGroups',
    :foreign_key             => self.primary_key,
    :association_foreign_key => Group.primary_key

  has_one :parent,
    :class_name  => 'Usergroup',
    :foreign_key => 'parentusergroupid'

end
