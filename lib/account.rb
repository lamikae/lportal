class Account < ActiveRecord::Base
  set_table_name       :Account_
  set_primary_key      :accountId

  # com.liferay.portal.model.Account
  def liferay_class
    'com.liferay.portal.model.Account'
  end

  belongs_to :company,
    :foreign_key => Company.primary_key

  belongs_to :user,
    :foreign_key => User.primary_key

end
