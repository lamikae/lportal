class Emailaddress < ActiveRecord::Base
  set_table_name       :emailaddress
  set_primary_key      :emailaddressid

  public

  # com.liferay.portal.model.EmailAddress
  def liferay_class
    'com.liferay.portal.model.EmailAddress'
  end

  belongs_to :company,
    :foreign_key => 'companyid'

  belongs_to :user,
    :foreign_key => 'userid'

end
