class Account < ActiveRecord::Base
  set_table_name       :account_
  set_primary_key      :accountid

  # com.liferay.portal.model.Account
  def liferay_class
    'com.liferay.portal.model.Account'
  end

  belongs_to :company,
    :foreign_key => 'companyid'

  belongs_to :user,
    :foreign_key => 'userid'

end
