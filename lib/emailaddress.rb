class Emailaddress < ActiveRecord::Base

  belongs_to :company,
    :foreign_key => 'companyid'

  belongs_to :user,
    :foreign_key => 'userid'

end
