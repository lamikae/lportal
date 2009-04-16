class DlFolder < ActiveRecord::Base

  has_many :files,
    :class_name  => 'DlFile',
    :foreign_key => DlFile.primary_key

  belongs_to :company, :foreign_key => Company.primary_key

  belongs_to :user,    :foreign_key => User.primary_key
  alias :owner :user

  belongs_to :group,   :foreign_key => Group.primary_key
  alias :community :group

#   has_one :asset,
#     :class_name  => 'Tag::Asset',
#     :foreign_key => 'classpk'

end
