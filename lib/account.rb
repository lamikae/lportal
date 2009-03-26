class Account < ActiveRecord::Base
  set_table_name       :Account_
  set_primary_key      :accountId

  # com.liferay.portal.model.Account
  def liferay_class
    'com.liferay.portal.model.Account'
  end

  # belongs to Company
  def company
    Company.find(self.send(Company.primary_key))
  end

  # belongs to User
  def user
    User.find(self.send(User.primary_key))
  end

end
