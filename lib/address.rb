class Address < ActiveRecord::Base

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
