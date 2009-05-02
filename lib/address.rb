class Address < ActiveRecord::Base

  belongs_to :company,
    :foreign_key => Company.primary_key

  belongs_to :user,
    :foreign_key => User.primary_key

  def initialize(params)
    super(params)
    self.createdate          = Time.now
    self.modifieddate        = Time.now
  end

end
