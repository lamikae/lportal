class Address < ActiveRecord::Base
  set_table_name       :address
  set_primary_key      :addressid

  public

  # com.liferay.portal.model.Address
  def liferay_class
    'com.liferay.portal.model.Address'
  end

  belongs_to :company,
    :foreign_key => 'companyid'

  belongs_to :user,
    :foreign_key => 'userid'


  def initialize(params)
    super(params)
    self.createdate          = Time.now
    self.modifieddate        = Time.now
  end

end
